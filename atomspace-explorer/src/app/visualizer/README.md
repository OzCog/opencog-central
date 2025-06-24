# AtomSpace Visualizer Module

This module contains the in-repo implementation of the atomspace visualization functionality, replacing the external `ng2-atomspace-visualizer` NPM package.

## Overview

The visualizer module provides D3.js-based hypergraph visualization capabilities for AtomSpace data structures. It includes:

- **VisualizerComponent**: Main Angular component for rendering the D3 force-directed graph
- **AtomService**: Service for managing atom data and state
- **VisualizerService**: Service for processing atom data into graph structures
- **Models**: TypeScript interfaces for Node, Link, and Graph data structures
- **Translation**: Multi-language support for the UI
- **Assets**: Sample data files and images

## Key Features

- Interactive D3.js force-directed graph visualization
- Node and link filtering capabilities
- Multi-language support (English, Chinese, French, German, Italian, Japanese, Spanish)
- Atom attention value (STI) visualization
- Context menus and interactive controls
- Responsive design

## Usage

Import the module in your Angular application:

```typescript
import { VisualizerModule } from './visualizer/visualizer.module';

@NgModule({
  imports: [
    VisualizerModule.forRoot()
  ]
})
export class AppModule { }
```

Use the component in templates:

```html
<cog-visualizer [atoms]="atomData"></cog-visualizer>
```

## Migration from ng2-atomspace-visualizer

This module replaces the external `ng2-atomspace-visualizer` package with identical functionality. All imports should be updated to reference the local module:

- Old: `import { VisualizerComponent } from 'ng2-atomspace-visualizer';`
- New: `import { VisualizerComponent } from './visualizer/visualizer.component';`

## Dependencies

- D3.js v4.11.0+ for graph visualization
- Angular 5+ framework
- TypeScript
- d3-context-menu for interactive menus