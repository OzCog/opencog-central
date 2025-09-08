import { Injectable, EventEmitter } from '@angular/core';
import { Observable, Subject, throwError } from 'rxjs';
import { configs } from '../../app.config';

// Interface definitions based on the modern AtomSpace API
export interface AtomBase {
    type: string;
    name?: string;
    outgoing?: AtomBase[];
}

interface ValueNode {
    name?: string;
    type: string;
    value: ValueNode | Array<any> | string | number;
}

interface AtomKeyValuePair {
    key: AtomBase;
    value: ValueNode;
}

@Injectable()
export class AtomSpaceWebSocketService {
    private websocket: WebSocket | null = null;
    private messageSubject = new Subject<any>();
    private isConnected = false;
    
    public static toastMessageEvent = new EventEmitter();

    constructor() {}

    /**
     * Connect to the AtomSpace CogServer WebSocket endpoint
     */
    connect(url: string = 'ws://localhost:18080/json'): Promise<boolean> {
        return new Promise((resolve, reject) => {
            try {
                this.websocket = new WebSocket(url);

                this.websocket.onopen = () => {
                    console.log('Connected to AtomSpace WebSocket:', url);
                    this.isConnected = true;
                    AtomSpaceWebSocketService.toastMessageEvent.emit({
                        msg: 'Connected to AtomSpace',
                        title: 'Success'
                    });
                    resolve(true);
                };

                this.websocket.onmessage = (event) => {
                    try {
                        const trimmedResponse = this.trimTrailJson(event.data);
                        const data = JSON.parse(trimmedResponse);
                        this.messageSubject.next(data);
                    } catch (error) {
                        console.error('Error parsing WebSocket message:', error);
                        this.messageSubject.error(error);
                    }
                };

                this.websocket.onerror = (error) => {
                    console.error('WebSocket error:', error);
                    this.isConnected = false;
                    AtomSpaceWebSocketService.toastMessageEvent.emit({
                        msg: 'WebSocket connection error',
                        title: 'Error'
                    });
                    reject(error);
                };

                this.websocket.onclose = () => {
                    console.log('WebSocket connection closed');
                    this.isConnected = false;
                    AtomSpaceWebSocketService.toastMessageEvent.emit({
                        msg: 'Connection to AtomSpace closed',
                        title: 'Warning'
                    });
                };

            } catch (error) {
                reject(error);
            }
        });
    }

    /**
     * Disconnect from the WebSocket
     */
    disconnect(): void {
        if (this.websocket) {
            this.websocket.close();
            this.websocket = null;
            this.isConnected = false;
        }
    }

    /**
     * Check if connected to the WebSocket
     */
    isSocketConnected(): boolean {
        return this.isConnected && this.websocket !== null && this.websocket.readyState === WebSocket.OPEN;
    }

    /**
     * Send a command to the AtomSpace and wait for response
     */
    private sendCommand(command: string): Promise<any> {
        return new Promise((resolve, reject) => {
            if (!this.isSocketConnected()) {
                reject(new Error('WebSocket not connected'));
                return;
            }

            console.log('S>', command);

            // Set up a one-time listener for the response
            const subscription = this.messageSubject.subscribe(
                (response) => {
                    console.log('R>', response);
                    subscription.unsubscribe();
                    resolve(response);
                },
                (error) => {
                    subscription.unsubscribe();
                    reject(error);
                }
            );

            // Send the command
            this.websocket!.send(command);

            // Set a timeout for the response
            setTimeout(() => {
                subscription.unsubscribe();
                reject(new Error('Command timeout'));
            }, +configs.opencog_url_timeout || 10000);
        });
    }

    /**
     * Get all atoms from the AtomSpace
     */
    async getAllAtoms(): Promise<AtomBase[]> {
        try {
            const command = 'AtomSpace.getAtoms("Atom",true)';
            const response = await this.sendCommand(command);
            return Array.isArray(response) ? response : [];
        } catch (error) {
            console.error('Error getting all atoms:', error);
            throw error;
        }
    }

    /**
     * Create a new atom in the AtomSpace
     */
    async makeAtom(newAtom: AtomBase): Promise<AtomBase> {
        try {
            const command = `AtomSpace.makeAtom(${JSON.stringify(newAtom)})`;
            const response = await this.sendCommand(command);
            
            if (response === true || response === 'true') {
                return newAtom;
            } else {
                throw new Error('AtomSpace rejected the atom insertion');
            }
        } catch (error) {
            console.error('Error creating atom:', error);
            throw error;
        }
    }

    /**
     * Check if an atom exists in the AtomSpace
     */
    async haveAtom(atomToCheck: AtomBase): Promise<boolean> {
        try {
            const command = `AtomSpace.haveAtom(${JSON.stringify(atomToCheck)})`;
            const response = await this.sendCommand(command);
            return response === true || response === 'true';
        } catch (error) {
            console.error('Error checking atom existence:', error);
            throw error;
        }
    }

    /**
     * Get incoming links for an atom
     */
    async getIncoming(atomToQuery: AtomBase): Promise<AtomBase[]> {
        try {
            const command = `AtomSpace.getIncoming(${JSON.stringify(atomToQuery)})`;
            const response = await this.sendCommand(command);
            return Array.isArray(response) ? response : [];
        } catch (error) {
            console.error('Error getting incoming links:', error);
            throw error;
        }
    }

    /**
     * Get values associated with an atom
     */
    async getValues(atomToQuery: AtomBase): Promise<AtomKeyValuePair[]> {
        try {
            const command = `AtomSpace.getValues(${JSON.stringify(atomToQuery)})`;
            const response = await this.sendCommand(command);
            return Array.isArray(response) ? response : [];
        } catch (error) {
            console.error('Error getting atom values:', error);
            throw error;
        }
    }

    /**
     * Get the truth value of an atom
     */
    async getTruthValue(atomToQuery: AtomBase): Promise<ValueNode[]> {
        try {
            const command = `AtomSpace.getTV(${JSON.stringify(atomToQuery)})`;
            const response = await this.sendCommand(command);
            return Array.isArray(response) ? response : [];
        } catch (error) {
            console.error('Error getting truth value:', error);
            throw error;
        }
    }

    /**
     * Send a raw string command to the AtomSpace
     */
    async sendRawString(rawString: string): Promise<string> {
        try {
            const response = await this.sendCommand(rawString);
            return typeof response === 'string' ? response : JSON.stringify(response);
        } catch (error) {
            console.error('Error sending raw string:', error);
            throw error;
        }
    }

    /**
     * Get the AtomSpace JSON API version
     */
    async getVersion(): Promise<string> {
        try {
            const response = await this.sendCommand('AtomSpace.version()');
            return typeof response === 'string' ? response : JSON.stringify(response);
        } catch (error) {
            console.error('Error getting version:', error);
            throw error;
        }
    }

    /**
     * Utility function to trim trailing 'json' from responses
     */
    private trimTrailJson(res: string): string {
        const trailingString = res.substring(res.length - 6);
        if (trailingString.includes('json')) {
            console.log(`Trimmed: ${trailingString}`);
            return res.substring(0, res.length - 6);
        } else {
            return res;
        }
    }

    /**
     * Convert this service to be compatible with the existing UrlConnectService interface
     */
    public get(path: string): Observable<any> {
        if (path.endsWith('.json')) {
            // Handle sample data files - fall back to HTTP for assets
            return new Observable(observer => {
                fetch(path)
                    .then(response => response.json())
                    .then(data => {
                        observer.next(data);
                        observer.complete();
                    })
                    .catch(error => {
                        observer.error(error);
                    });
            });
        } else {
            // Handle AtomSpace API calls via WebSocket
            return new Observable(observer => {
                if (!this.isSocketConnected()) {
                    observer.error(new Error('Not connected to AtomSpace WebSocket'));
                    return;
                }

                this.getAllAtoms()
                    .then(atoms => {
                        observer.next(atoms);
                        observer.complete();
                    })
                    .catch(error => {
                        observer.error(error);
                    });
            });
        }
    }
}