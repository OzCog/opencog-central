
# This file reads files that are generated by the OPENCOG_ADD_ATOM_TYPES
# macro so they can be imported using:
#
# from type_constructors import *
#
# This imports all the python wrappers for atom creation.
#
from opencog.atomspace cimport strength_t, confidence_t

import warnings

from opencog.atomspace import (createFloatValue, createLinkValue,
                               createStringValue, createTruthValue)
from opencog.atomspace import types, AtomSpace
from opencog.utilities import add_node, add_link
from opencog.utilities import get_default_atomspace, set_default_atomspace


def set_type_ctor_atomspace(new_atomspace):
    warnings.warn('set_type_ctor_atomspace is deprecated, use set_default_atomspace instead',
            DeprecationWarning)
    return set_default_atomspace(new_atomspace)


def get_type_ctor_atomspace():
    warnings.warn('get_type_ctor_atomspace is deprecated, use get_default_atomspace instead',
            DeprecationWarning)
    return get_default_atomspace()


include "opencog/atoms/atom_types/core_types.pyx"


def FloatValue(arg):
    return createFloatValue(arg)


def LinkValue(arg):
    return createLinkValue(arg)


def StringValue(arg):
    return createStringValue(arg)


def TruthValue(strength_t strength=1.0, confidence_t confidence=1.0):
    return createTruthValue(strength, confidence)