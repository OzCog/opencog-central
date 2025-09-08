import { Injectable } from '@angular/core';
import { AtomBase } from './atomspace-websocket.service';

interface OldFormatAtom {
  handle: number;
  name: string;
  type: string;
  outgoing: number[];
  incoming: number[];
  truthvalue?: any;
  attentionvalue?: any;
}

interface OldFormatResponse {
  result: {
    atoms: OldFormatAtom[];
  };
}

interface NewFormatResponse {
  result: {
    atoms: AtomBase[];
  };
}

@Injectable()
export class AtomDataAdapter {

  /**
   * Convert new format atoms to old format structure for compatibility
   */
  convertNewToOldFormat(newFormatAtoms: AtomBase[]): OldFormatResponse {
    const convertedAtoms: OldFormatAtom[] = [];
    const atomMap = new Map<string, number>(); // For handle assignment
    let handleCounter = 0;

    // First pass: create all atoms and assign handles
    newFormatAtoms.forEach(atom => {
      const atomKey = this.getAtomKey(atom);
      if (!atomMap.has(atomKey)) {
        atomMap.set(atomKey, handleCounter++);
      }
    });

    // Second pass: convert atoms
    newFormatAtoms.forEach(atom => {
      const converted: OldFormatAtom = {
        handle: atomMap.get(this.getAtomKey(atom))!,
        name: atom.name || '',
        type: atom.type,
        outgoing: [],
        incoming: [],
        // Add default values for compatibility
        truthvalue: {
          type: 'simple',
          details: {
            count: 1.0,
            confidence: 1.0,
            strength: 1.0
          }
        },
        attentionvalue: {
          lti: 0,
          sti: 0,
          vlti: false
        }
      };

      // Convert outgoing links from atoms to handles
      if (atom.outgoing) {
        atom.outgoing.forEach(outgoingAtom => {
          const outgoingKey = this.getAtomKey(outgoingAtom);
          const outgoingHandle = atomMap.get(outgoingKey);
          if (outgoingHandle !== undefined) {
            converted.outgoing.push(outgoingHandle);
          }
        });
      }

      convertedAtoms.push(converted);
    });

    // Third pass: calculate incoming links
    convertedAtoms.forEach((atom, index) => {
      atom.outgoing.forEach(outgoingHandle => {
        if (convertedAtoms[outgoingHandle]) {
          convertedAtoms[outgoingHandle].incoming.push(index);
        }
      });
    });

    return {
      result: {
        atoms: convertedAtoms
      }
    };
  }

  /**
   * Convert old format to new format
   */
  convertOldToNewFormat(oldFormatResponse: OldFormatResponse): AtomBase[] {
    const atoms = oldFormatResponse.result.atoms;
    const handleToAtom = new Map<number, AtomBase>();

    // First pass: create all atoms
    atoms.forEach(atom => {
      const newAtom: AtomBase = {
        type: atom.type,
        name: atom.name || undefined
      };
      handleToAtom.set(atom.handle, newAtom);
    });

    // Second pass: resolve outgoing links
    atoms.forEach(atom => {
      if (atom.outgoing && atom.outgoing.length > 0) {
        const currentAtom = handleToAtom.get(atom.handle)!;
        currentAtom.outgoing = atom.outgoing.map(handle => handleToAtom.get(handle)!).filter(a => a);
      }
    });

    return Array.from(handleToAtom.values());
  }

  /**
   * Detect if response is in old or new format and normalize to old format
   */
  normalizeToOldFormat(response: any): OldFormatResponse {
    // Check if it's already in old format
    if (response.result && response.result.atoms && response.result.atoms.length > 0) {
      const firstAtom = response.result.atoms[0];
      if (firstAtom.hasOwnProperty('handle')) {
        // Already in old format
        return response as OldFormatResponse;
      }
    }

    // Check if it's an array of new format atoms
    if (Array.isArray(response)) {
      return this.convertNewToOldFormat(response);
    }

    // Check if it's new format wrapped in an object
    if (response.atoms && Array.isArray(response.atoms)) {
      return this.convertNewToOldFormat(response.atoms);
    }

    // If we can't determine the format, create an empty response
    console.warn('Unknown atom data format, creating empty response');
    return {
      result: {
        atoms: []
      }
    };
  }

  /**
   * Create a unique key for an atom
   */
  private getAtomKey(atom: AtomBase): string {
    if (atom.name) {
      return `${atom.type}:${atom.name}`;
    }
    // For links without names, create key based on outgoing structure
    if (atom.outgoing) {
      const outgoingKeys = atom.outgoing.map(a => this.getAtomKey(a)).join(',');
      return `${atom.type}:[${outgoingKeys}]`;
    }
    return `${atom.type}:anonymous`;
  }

  /**
   * Create sample data in new format
   */
  createSampleData(): AtomBase[] {
    return [
      {
        type: 'ConceptNode',
        name: 'Socrates'
      },
      {
        type: 'ConceptNode',
        name: 'man'
      },
      {
        type: 'ConceptNode',
        name: 'mortal'
      },
      {
        type: 'InheritanceLink',
        outgoing: [
          { type: 'ConceptNode', name: 'Socrates' },
          { type: 'ConceptNode', name: 'man' }
        ]
      },
      {
        type: 'InheritanceLink',
        outgoing: [
          { type: 'ConceptNode', name: 'man' },
          { type: 'ConceptNode', name: 'mortal' }
        ]
      }
    ];
  }
}