import { Injectable, EventEmitter } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { timeout, catchError, map } from 'rxjs/operators';
import { of } from 'rxjs';
import { configs } from '../../app.config';
import { AtomSpaceWebSocketService } from './atomspace-websocket.service';
import { AtomDataAdapter } from './atom-data-adapter.service';

@Injectable()
export class UrlConnectService {
  headers: HttpHeaders = new HttpHeaders({
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Headers': 'Accept-Ranges',
    'authorization': ''
  });

  public static toastMessageEvent = new EventEmitter();

  constructor(
    private _http: HttpClient, 
    private wsService: AtomSpaceWebSocketService,
    private dataAdapter: AtomDataAdapter
  ) {}

  public get(path: string): Observable<any> {
    const api_timeout: number = +configs.opencog_url_timeout;

    // Handle sample JSON files from assets
    if (path.endsWith('.json')) {
      return this._http.get(path, { headers: this.headers })
        .pipe(
          timeout(api_timeout),
          map(response => {
            // Convert to old format if it's new format
            return this.dataAdapter.normalizeToOldFormat(response);
          }),
          catchError(this.handleError.bind(this))
        );
    }

    // Handle WebSocket URLs (ws:// or wss://)
    if (path.startsWith('ws://') || path.startsWith('wss://')) {
      return new Observable(observer => {
        this.wsService.connect(path)
          .then(() => {
            console.log('Connected to WebSocket, fetching atoms...');
            return this.wsService.getAllAtoms();
          })
          .then(atoms => {
            console.log('Retrieved atoms from WebSocket:', atoms.length);
            // Convert new format to old format for compatibility
            const oldFormat = this.dataAdapter.convertNewToOldFormat(atoms);
            observer.next(oldFormat);
            observer.complete();
          })
          .catch(error => {
            console.error('WebSocket error:', error);
            observer.error(error);
          });
      });
    }

    // Legacy HTTP API (for backwards compatibility)
    const api_urlroot: string = configs.atomspace_api;
    const url = `${path}${api_urlroot}/atoms`;

    return this._http.get(url, { headers: this.headers })
      .pipe(
        timeout(api_timeout),
        catchError(this.handleError.bind(this))
      );
  }

  private setHeaders(token) {
    this.headers = this.headers.set('authorization', token);
  }

  private handleError(response) {
    const err = { status: 0, message: '' };
    const errtitle = 'Error';
    err.status = response.status ? response.status : 0;
    err.message = response.statusText ? response.statusText : 'Unknown Error';

    console.log(response);

    if (response.ok) {
      return of(response);
    } else if (response instanceof SyntaxError) {
      err.message = 'Syntax Error';
      UrlConnectService.toastMessageEvent.emit({ msg: err.message, title: errtitle });
    // } else if (response instanceof TimeoutError ) {
    } else if (response.name && response.name === 'TimeoutError') {
      err.message = 'Timeout Error';
      UrlConnectService.toastMessageEvent.emit({ msg: err.message, title: errtitle });
    } else if (response.status === 0) {
      err.message = 'The Server is down or unreachable';
      UrlConnectService.toastMessageEvent.emit({ msg: err.message, title: errtitle });
    } else if (response.status === 422) {
      // Typically means request body is well-formed (i.e. syntactically correct), but semantically erroneous
      // UrlConnectService.toastMessageEvent.emit({msg:"Uprocesseable Entity!", title:"Validation Error"});
      // let the component handle the error
    } else if (response.status === 400) {
      err.message = '400 Bad Request';
      UrlConnectService.toastMessageEvent.emit({ msg: err.message, title: errtitle });
    } else if (response.status === 401) {
      err.message = '401 Unauthorized';
      UrlConnectService.toastMessageEvent.emit({ msg: err.message, title: errtitle });
    } else if (response.status === 404) {
      err.message = '404 Not Found';
      UrlConnectService.toastMessageEvent.emit({ msg: err.message, title: errtitle });
    } else if (response.status === 500) {
      err.message = '500 Internal Server Error';
      UrlConnectService.toastMessageEvent.emit({ msg: err.message, title: errtitle });
    }
    return of(err);
  }
}
