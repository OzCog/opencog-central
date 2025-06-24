import { AtomService, AtomServiceData } from '../src/app/visualizer/atom.service';
import { VisualizerService } from '../src/app/visualizer/visualizer.service';

describe('Visualizer Module Integration', () => {
  let atomService: AtomService;
  let visualizerService: VisualizerService;

  beforeEach(() => {
    atomService = new AtomService();
    visualizerService = new VisualizerService();
  });

  it('should create AtomService instance', () => {
    expect(atomService).toBeDefined();
  });

  it('should create VisualizerService instance', () => {
    expect(visualizerService).toBeDefined();
  });

  it('should process empty atom data', () => {
    const emptyAtoms = [];
    const result = visualizerService.getParsedJson(emptyAtoms);
    
    expect(result).toBeDefined();
    expect(result.nodes).toBeDefined();
    expect(result.links).toBeDefined();
    expect(Array.isArray(result.nodes)).toBe(true);
    expect(Array.isArray(result.links)).toBe(true);
  });

  it('should process atom data with basic node', () => {
    const testAtoms = [{
      handle: 'test-handle-1',
      name: 'TestNode',
      type: 'ConceptNode'
    }];
    
    const result = visualizerService.getParsedJson(testAtoms);
    
    expect(result.nodes.length).toBe(1);
    expect(result.nodes[0].id).toBe('test-handle-1');
    expect(result.nodes[0].name).toBe('TestNode');
  });
});