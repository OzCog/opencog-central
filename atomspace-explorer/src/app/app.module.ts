import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatButtonModule, MatCardModule, MatMenuModule, MatToolbarModule, MatIconModule, MatAutocompleteModule, MatInputModule,
  MatFormFieldModule } from '@angular/material';
import 'hammerjs';
import { ToastModule } from 'ng2-toastr';
import { AppComponent } from './app.component';
import { RouterModule } from '@angular/router';
import { APP_ROUTES } from './app.routes';
import { FlexLayoutModule } from '@angular/flex-layout';
import { AuthModule } from './core/auth/auth.module';
import { SharedModule } from './shared/shared.module';
import { MainContainer } from './shared/ui/main-container.component';
import { APIService } from './shared/services/api.service';
import { TranslateModule } from './core/translate/translate.module';
import { InitializeDropdown } from './shared/directives/intitialise-dropdown.directive';
import { ConnectModule } from './connect/connect.module';
import { LocalStorageModule } from 'angular-2-local-storage';
import { VisualizerModule } from './visualizer/visualizer.module';

@NgModule({
  declarations: [
      AppComponent,
      MainContainer
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpClientModule,
    AuthModule,
    RouterModule,
    RouterModule.forRoot(APP_ROUTES, {useHash: true}),
    FlexLayoutModule,
    SharedModule,
    TranslateModule,
    ToastModule.forRoot(),
    ConnectModule,
    LocalStorageModule.withConfig({
      prefix: 'my-app',
      storageType: 'localStorage'
    }),
    VisualizerModule.forRoot()
  ],
  providers: [ APIService ],
  bootstrap: [ AppComponent ],
})

export class AppModule { }
