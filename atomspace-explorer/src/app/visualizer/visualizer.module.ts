import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { VisualizerComponent } from './visualizer.component';
import { AtomService } from './atom.service';
import { VisualizerService } from './visualizer.service';
import { InitializeDropdown } from './directives/intialize-dropdown.directive';
import { TranslateModule } from './translate/translate.module';

@NgModule({
  imports: [
    CommonModule,
    TranslateModule
  ],
  declarations: [ VisualizerComponent, InitializeDropdown ],
  exports: [ VisualizerComponent ]
})
export class VisualizerModule {
  static forRoot() {
    return {
      ngModule: VisualizerModule,
      providers: [ VisualizerService, AtomService ]
    };
  }
}