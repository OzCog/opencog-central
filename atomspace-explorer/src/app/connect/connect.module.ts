import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { UrlConnectComponent } from './url-connect/url-connect.component';
import { UrlConnectService } from './url-connect/url-connect.service';
import { AtomSpaceWebSocketService } from './url-connect/atomspace-websocket.service';
import { AtomDataAdapter } from './url-connect/atom-data-adapter.service';
import { SharedModule } from '../shared/shared.module';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    SharedModule
  ],
  declarations: [UrlConnectComponent],
  providers: [UrlConnectService, AtomSpaceWebSocketService, AtomDataAdapter]
})

export class ConnectModule { }
