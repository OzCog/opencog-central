
/** AtomSpaceBenchmark.cc */

#include <ctime>
#include <iostream>
#include <fstream>
#include <sys/time.h>
#include <sys/resource.h>

#include <boost/tuple/tuple_io.hpp>

#include <opencog/util/oc_assert.h>
#include <opencog/util/random.h>

#include <opencog/atoms/atom_types/types.h>
#include <opencog/atoms/base/Node.h>
#include <opencog/atoms/base/Link.h>
#include <opencog/atoms/truthvalue/CountTruthValue.h>
#include <opencog/atoms/truthvalue/IndefiniteTruthValue.h>
#include <opencog/atoms/truthvalue/SimpleTruthValue.h>
#include <opencog/atoms/truthvalue/TruthValue.h>
#include <opencog/persist/tlb/TLB.h>
#include <opencog/guile/SchemeEval.h>

#include "AtomSpaceBenchmark.h"

#ifdef HAVE_CYTHON
#include <opencog/cython/PythonEval.h>
#endif

const char* VERSION_STRING = "Version 1.1.1";

namespace opencog {

using namespace boost;
using std::cout;
using std::cerr;
using std::flush;
using std::endl;
using std::clock;
using std::time;

#define DIVIDER_LINE "------------------------------"
#define PROGRESS_BAR_LENGTH 10

#define GUILE_SYMB "foo"
#define GUILE_FUNB "fnu"

TLB tlbuf;

AtomSpaceBenchmark::AtomSpaceBenchmark()
{
    percentLinks = 0.2;

    // Create an atomspace with a quarter-million atoms
    // This is quasi-realistic for an atomspace doing language processing.
    // Maybe a bit on the small side ...
    atomCount = (1 << 18);
    defaultNodeType = CONCEPT_NODE;
    chanceOfNonDefaultNode = 0.4f;
    defaultLinkType = INHERITANCE_LINK;
    chanceOfNonDefaultLink = 0.4f;
    linkSize_mean = 2.0f;
    poissonDistribution = new std::poisson_distribution<unsigned>(linkSize_mean);

    counter = 0;
    showTypeSizes = false;
    baseNclock = 2000;
    baseNreps = 800 * baseNclock;
    baseNloops = 1;
    Nreserve = 0;

    memoize = false;
    compile = false;
    sizeIncrease = 0;
    saveToFile = false;
    saveInterval = 1;
    buildTestData = false;
    chanceUseDefaultTV = 0.8f;
    doStats = false;
    testKind = BENCH_AS;

    randomseed = (unsigned long) time(NULL);

    asp = NULL;
    randomGenerator = NULL;
}

AtomSpaceBenchmark::~AtomSpaceBenchmark()
{
    delete poissonDistribution;
    delete randomGenerator;
}

// This is wrong, because it fails to count also the amount of RAM
// used by the AtomTable to store indexes.
size_t AtomSpaceBenchmark::estimateOfAtomSize(Handle h)
{
    size_t total = 0;
    if (h->getTruthValue() != TruthValue::DEFAULT_TV())
    {
        Type tvt = h->getTruthValue()->get_type();
        if (tvt == SIMPLE_TRUTH_VALUE)
            total += sizeof(SimpleTruthValue);
        else
        if (tvt == COUNT_TRUTH_VALUE)
            total += sizeof(CountTruthValue);
        else
        if (tvt == INDEFINITE_TRUTH_VALUE)
            total += sizeof(IndefiniteTruthValue);
    }

    NodePtr n(NodeCast(h));
    if (n)
    {
        total = sizeof(Node);
        total += n->get_name().capacity();
    }
    else
    {
        LinkPtr l(LinkCast(h));
        total = sizeof(Link);
        total += l->getOutgoingSet().capacity() * sizeof(Handle);
        for (Handle ho: l->getOutgoingSet())
        {
            total += estimateOfAtomSize(ho);
        }
    }

    return total;
}

long AtomSpaceBenchmark::getMemUsage()
{
    // getrusage is the best option it seems...
    // on linux /proc/pid/status and other files may have more detail
    struct rusage *s = (struct rusage *) malloc(sizeof(struct rusage));
    getrusage(RUSAGE_SELF,s);
    long rss = s->ru_maxrss;
    free(s);
    return rss;
}

void AtomSpaceBenchmark::printTypeSizes()
{
    // Note that these are just the type size, it doesn't include the size of
    // data/classes that these might point to.
    //cout << "CLOCKS_PER_SEC = " << CLOCKS_PER_SEC << endl;
    cout << "==sizeof() on various classes==" << endl;
    cout << "FIXME: the report below is only for the sizes of the C++ objects\n"
         << "themselves.  In addition, every atom consumes from 5 to 15 times\n"
         << "the sizeof(Handle) in the AtomTable indexes. This depends on the\n"
         << "atom type; Links store more than twice the the sizeof(Handle) per\n"
         << "outgoing atoms.\n";
    cout << "Type = " << sizeof(Type) << endl;
    cout << "Handle = " << sizeof(Handle) << endl;
    cout << "Atom = " << sizeof(Atom) << endl;
    cout << "Node = " << sizeof(Node) << endl;
    cout << "Link = " << sizeof(Link) << endl;
    cout << "SimpleTruthValue = " << sizeof(SimpleTruthValue) << endl;
    cout << "CountTruthValue = " << sizeof(CountTruthValue) << endl;
    cout << "IndefiniteTruthValue = " << sizeof(IndefiniteTruthValue) << endl;
    cout << "IncomingSet = " << sizeof(IncomingSet) << endl;
    cout << DIVIDER_LINE << endl;

#define ND(T,S) ({Handle n(createNode(T,S)); n;})
#define LK(T,A,B) ({Handle l(createLink(T,A,B)); l;})
    Handle h = ND(CONCEPT_NODE, "this is a test");
    cout << "ConceptNode \"this is a test\" = "
         << estimateOfAtomSize(h) << endl;

    h = createLink(LIST_LINK);
    cout << "Empty ListLink = " << estimateOfAtomSize(h) << endl;

    Handle na = ND(CONCEPT_NODE, "first atom");
    Handle nb = ND(CONCEPT_NODE, "second atom");
    Handle ll = LK(LIST_LINK, na, nb);
    cout << "ListLink with two ConceptNodes = "
         << estimateOfAtomSize(ll) << endl;

    Handle np = ND(PREDICATE_NODE, "some predicate");
    Handle el = LK(EVALUATION_LINK, np, ll);
    cout << "EvaluationLink with two ConceptNodes = "
         << estimateOfAtomSize(el) << endl;
}

void AtomSpaceBenchmark::showMethods()
{
    /// @todo should really encapsulate each test method in a struct or class
    cout << "Methods that can be tested:" << endl;
    cout << "  getType" << endl;
    cout << "  getTruthValue" << endl;
    cout << "  setTruthValue" << endl;
#ifdef ZMQ_EXPERIMENT
    cout << "  getTruthValueZMQ" << endl;
#endif
    cout << "  getOutgoingSet" << endl;
    cout << "  getIncomingSet" << endl;
    cout << "  getIncomingSetSize" << endl;
    cout << "  addNode" << endl;
    cout << "  addLink" << endl;
    cout << "  removeAtom" << endl;
    cout << "  getHandlesByType" << endl;
    cout << "  push_back" << endl;
    cout << "  emplace_back" << endl;
    cout << "  reserve" << endl;
}

void AtomSpaceBenchmark::setMethod(std::string methodToTest)
{
    bool foundMethod = false;

    if (methodToTest == "all" or methodToTest == "noop") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_noop);
        methodNames.push_back("noop");
        foundMethod = true;
    }
    if (methodToTest == "all" or methodToTest == "getType") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_getType);
        methodNames.push_back("getType");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "getTruthValue") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_getTruthValue);
        methodNames.push_back("getTruthValue");
        foundMethod = true;
    }

#ifdef ZMQ_EXPERIMENT
    if (methodToTest == "all" or methodToTest == "getTruthValueZMQ") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_getTruthValueZmq);
        methodNames.push_back("getTruthValueZMQ");
        foundMethod = true;
    }
#endif

    if (methodToTest == "all" or methodToTest == "setTruthValue") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_setTruthValue);
        methodNames.push_back("setTruthValue");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "pointerCast") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_pointerCast);
        methodNames.push_back("pointerCast");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "getIncomingSet") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_getIncomingSet);
        methodNames.push_back("getIncomingSet");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "getIncomingSetSize") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_getIncomingSetSize);
        methodNames.push_back("getIncomingSetSize");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "getOutgoingSet") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_getOutgoingSet);
        methodNames.push_back("getOutgoingSet");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "addNode") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_addNode);
        methodNames.push_back("addNode");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "addLink") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_addLink);
        methodNames.push_back("addLink");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "removeAtom") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_rmAtom);
        methodNames.push_back("removeAtom");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "getHandlesByType") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_getHandlesByType);
        methodNames.push_back("getHandlesByType");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "push_back") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_push_back);
        methodNames.push_back("push_back");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "push_back_reserve") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_push_back_reserve);
        methodNames.push_back("push_back_reserve");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "emplace_back") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_emplace_back);
        methodNames.push_back("emplace_back");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "emplace_back_reserve") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_emplace_back_reserve);
        methodNames.push_back("emplace_back_reserve");
        foundMethod = true;
    }

    if (methodToTest == "all" or methodToTest == "reserve") {
        methodsToTest.push_back( &AtomSpaceBenchmark::bm_reserve);
        methodNames.push_back("reserve");
        foundMethod = true;
    }

    if (!foundMethod) {
        std::cerr << "Error: specified a bad test name: " << methodToTest << std::endl;
        exit(1);
    }

}

#define CALL_MEMBER_FN(object,ptrToMember)  ((object).*(ptrToMember))
void AtomSpaceBenchmark::doBenchmark(const std::string& methodName,
                                     BMFn methodToCall)
{
    Nclock = baseNclock;
    Nloops = baseNloops;
    Nreps = baseNreps / Nclock;
#ifdef HAVE_GUILE
    if (BENCH_SCM == testKind /* or BENCH_PYTHON == testKind */)
    {
        // Try to avoid excessive compilation times.
        Nreps = (100 * baseNreps) / Nclock;
        Nclock /= 100;

        // Basic non-craziness.
        if (scm->input_pending() or scm->eval_error())
        {
            printf("Fatal Error: guile evaluator in crazy state!\n");
            exit(1);
        }
    }
#endif // HAVE_GUILE

    // Must not remove more atoms than there are
    if (methodToCall == &AtomSpaceBenchmark::bm_rmAtom)
    {
        size_t asz = asp->get_size();
        if (asz < 4*Nreps*Nclock*Nloops/3)
            Nreps = asz / (4*Nclock*Nloops/3);
    }

    clock_t sumAsyncTime = 0;
    long rssStart;
    std::vector<record_t> records;
    cout << "Benchmarking ";
    switch (testKind) {
        case BENCH_AS:  cout << "AtomSpace's "; break;
#if HAVE_GUILE
        case BENCH_SCM:  cout << "Scheme's ";
        if (memoize) cout << "memoized ";
        else if (compile) cout << "compiled ";
        else cout << "interpreted ";
        break;
#endif /* HAVE_GUILE */
#if HAVE_CYTHON
        case BENCH_PYTHON: cout << "Python's "; break;
#endif /* HAVE_CYTHON */
    }
    cout << methodName << " method " << (Nclock*Nreps*Nloops) << " times ";
    std::ofstream myfile;
    if (saveToFile)
    {
        myfile.open ((methodName + "_benchmark.csv").c_str());
    }
    int diff = (Nreps / PROGRESS_BAR_LENGTH);
    if (!diff) diff = 1;
    int counter = 0;
    rssStart = getMemUsage();
    long rssFromIncrease = 0;
    timeval tim;
    gettimeofday(&tim, NULL);
    double t1 = tim.tv_sec + (tim.tv_usec/1000000.0);
    for (unsigned int i=0; i < Nreps; i++)
    {
        if (sizeIncrease)
        {
            long rssBeforeIncrease = getMemUsage();
            buildAtomSpace(sizeIncrease, percentLinks, false);
            // Try to negate the memory increase due to adding atoms
            rssFromIncrease += (getMemUsage() - rssBeforeIncrease);
        }
        size_t atomspaceSize = asp->get_size();
        timepair_t timeTaken = CALL_MEMBER_FN(*this, methodToCall)();
        sumAsyncTime += get<0>(timeTaken);
        counter++;
        if (saveInterval && counter % saveInterval == 0)
        {
            // Only save datapoints every saveInterval calls
            record_t dataPoint(atomspaceSize,get<0>(timeTaken),getMemUsage()-rssStart-rssFromIncrease);
            // Only save datapoints if we have to calculate the stats
            // afterwards, otherwise it affects memory usage
            if (doStats) {
                if (get<0>(timeTaken) < 0) cout << "ftumf" << endl;
                records.push_back(dataPoint);
            }
            // otherwise, we might write directly to a file
            if (saveToFile) recordToFile(myfile,dataPoint);
        }
        if (i % diff == 0) cerr << "." << flush;
    }
    Handle rh = getRandomHandle();
    gettimeofday(&tim, NULL);
    double t2 = tim.tv_sec + (tim.tv_usec/1000000.0);
    printf("\n%.6lf seconds elapsed (%.2f per second)\n",
         t2-t1, 1.0f / ((t2-t1) / (Nreps*Nclock)));
    // rssEnd = getMemUsage();
    cout << "Sum clock() time for all requests: " << sumAsyncTime << " (" <<
        (float) sumAsyncTime / CLOCKS_PER_SEC << " seconds, "<<
        1.0f/(((float)sumAsyncTime/CLOCKS_PER_SEC) / (Nreps*Nclock*Nloops)) << " requests per second)" << endl;
    //cout << "Memory (max RSS) change after benchmark: " <<
    //    (rssEnd - rssStart - rssFromIncrease) / 1024 << "kb" << endl;

    if (saveInterval && doStats)
    {
        // Only calculate stats if we've actually been saving datapoints
        // the option to calculate them is enabled
        AtomSpaceBenchmark::TimeStats t(records);
        t.print();
    }
    cout << DIVIDER_LINE << endl;
    if (saveToFile) { myfile.close(); }
}

// A totally bogus value for no particular reason
#define UUID_PAD 1000

void AtomSpaceBenchmark::startBenchmark(int numThreads)
{
    cout << "OpenCog Atomspace Benchmark - " << VERSION_STRING << "\n";
    cout << "\nRandom generator: MT19937\n";
    cout << "Random seed: " << randomseed << "\n\n";

    if (saveToFile) cout << "Ingnore this: " << global << std::endl;

    // Initialize the random number generator with the seed which might
    // have been passed in on the command line.
    if (randomGenerator)
        delete randomGenerator;
    randomGenerator = new opencog::MT19937RandGen(randomseed);

    // Make sure we are using the correct link mean!
    if (poissonDistribution) delete poissonDistribution;
    poissonDistribution = new std::poisson_distribution<unsigned>(linkSize_mean);

    // num threads does nothing at the moment;
    if (showTypeSizes) printTypeSizes();

    for (unsigned int i = 0; i < methodNames.size(); i++) {
        UUID_begin = 1;
        UUID_end = tlbuf.size() + UUID_PAD;
        asp = createAtomSpace();
#if HAVE_CYTHON
        pyev = new PythonEval();
        // And now ... create a Python instance of the atomspace.
        // Pass in the raw C++ atomspace address into cython.
        // Kind-of tacky, but I don't see any better way.
        // (We must do this because otherwise, the benchmark would
        // run on a different atomspace, than the one containing
        // all the atoms.  And that would give bad results.
        std::ostringstream dss;
        dss << "from atomspace import AtomSpace, types, TruthValue, Atom" << std::endl;
        dss << "aspace = AtomSpace(" << asp << ")" << std::endl;
        pyev->eval(dss.str());
#endif
#if HAVE_GUILE
        scm = new SchemeEval(asp);
#endif
        numberOfTypes = nameserver().getNumberOfClasses();

        if (buildTestData) buildAtomSpace(atomCount, percentLinks, false);
        UUID_end = tlbuf.size() + UUID_PAD;

        doBenchmark(methodNames[i], methodsToTest[i]);

#if HAVE_GUILE
        delete scm;
#endif
#if HAVE_CYTHON
        delete pyev;
#endif
    }

    //cout << estimateOfAtomSize(Handle(2)) << endl;
    //cout << estimateOfAtomSize(Handle(1020)) << endl;
}

std::string
AtomSpaceBenchmark::memoize_or_compile(std::string label, std::string exp)
{
#ifdef HAVE_GUILE
    std::string funlab = "(";
    funlab += label;
    funlab += ")";
    if (memoize)
    {
        std::ostringstream dss;
        dss << "(define " << funlab << " " << exp << ")\n";
        scm->eval(dss.str());
        return funlab + "\n";
    }
    if (compile)
    {
        std::ostringstream dss;
        dss << "(compile '(define " << funlab << " " << exp
            << ") #:env (current-module))\n";
        scm->eval(dss.str());
        return funlab + "\n";
    }
#endif /* HAVE_GUILE */
#if HAVE_CYTHON
    if (memoize)
    {
        std::ostringstream dss;
        dss << "def " << label << "():\n" << exp << "\n\n";
        pyev->eval(dss.str());
        return label + "()\n\n";
    }
#endif /* HAVE_CYTHON */

    return exp;
}

// Set the guile symbol id to the atom h.
void AtomSpaceBenchmark::guile_define(std::string id, Handle h)
{
    std::ostringstream ss;
    Type t = h->get_type();
    if (nameserver().isA(t, NODE)) {
        ss << "(define " << id << " (cog-new-node '"
           << nameserver().getTypeName(t)
           << " \"" << h->get_name() << "\"))\n";
    } else {
        HandleSeq oset = h->getOutgoingSet();
        Arity ary = oset.size();
        ss << "(define " << id << " (cog-new-link '"
           << nameserver().getTypeName(t) << " ";
        std::string symb = "bar";
        for (Arity i=0; i<ary; i++) {
            std::string osym = symb + std::to_string(i);
            guile_define(osym, oset[i]);
            ss << osym << " ";
        }
        ss << "))\n";
    }
    std::string result = scm->eval(ss.str());
    if (scm->eval_error()) {
        printf("Caught error %s\nWhile evaluating %s\n",
            result.c_str(), ss.str().c_str());
        exit(1);
    }
}

Type AtomSpaceBenchmark::randomType(Type t)
{
    OC_ASSERT(t < numberOfTypes);
    Type candidateType;

    // Loop until we get a type that is a subclass of t, skipping TYPE_NODE
    // since that type can't handle randomly generated names. Also skip
    // BIND_LINK and other validated types since the validation will fail.
    do {
        candidateType = ATOM + randomGenerator->randint(numberOfTypes - ATOM - 1);
    } while (!nameserver().isA(candidateType, t) or
        nameserver().isA(candidateType, BOOLEAN_INPUT_LINK) or
        nameserver().isA(candidateType, BOOLEAN_OUTPUT_LINK) or
        nameserver().isA(candidateType, CRISP_INPUT_LINK) or
        nameserver().isA(candidateType, CRISP_OUTPUT_LINK) or
        nameserver().isA(candidateType, NUMERIC_INPUT_LINK) or
        nameserver().isA(candidateType, NUMERIC_OUTPUT_LINK) or
        nameserver().isA(candidateType, TYPE_INPUT_LINK) or
        nameserver().isA(candidateType, TYPE_OUTPUT_LINK) or
        nameserver().isA(candidateType, EXECUTE_THREADED_LINK) or
        nameserver().isA(candidateType, FREE_LINK) or
        nameserver().isA(candidateType, SCOPE_LINK) or
        nameserver().isA(candidateType, UNIQUE_LINK) or
        nameserver().isA(candidateType, TYPED_VARIABLE_LINK) or
        candidateType == VARIABLE_LIST or
        candidateType == VARIABLE_SET or
        candidateType == DEFINE_LINK or
        candidateType == NUMBER_NODE or
        nameserver().isA(candidateType, TYPE_NODE));

    return candidateType;
}

clock_t AtomSpaceBenchmark::makeRandomNodes(const std::string& csi)
{
#ifdef FIXME_LATER
    // Some faction of the time, we create atoms with non-default
    // truth values.  XXX implement this for making of links too...
    bool useDefaultTV = (randomGenerator->randfloat() < chanceUseDefaultTV);
    SimpleTruthValue stv(TruthValue::DEFAULT_TV());

    if (not useDefaultTV) {
        float strength = randomGenerator->randfloat();
        float conf = randomGenerator->randfloat();
        stv = SimpleTruthValue(strength, conf);
    }
#endif

    double p = randomGenerator->randdouble();
    Type ta[Nclock];
    std::string nn[Nclock];
    for (unsigned int i = 0; i<Nclock; i++)
    {
        Type t = defaultNodeType;
        if (p < chanceOfNonDefaultNode)
            t = randomType(NODE);
        ta[i] = t;

        std::string scp(csi);
        if (csi.size() ==  0) {
            std::ostringstream oss;
            counter++;
            if (NUMBER_NODE == t)
                oss << counter;    // number nodes must actually be numbers.
            else
                oss << "node " << counter;
            scp = oss.str();
        }
        nn[i] = scp;
    }

    switch (testKind) {
    case BENCH_AS: {
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            asp->add_node(ta[i], std::move(nn[i]));
        return clock() - t_begin;
    }
#if HAVE_GUILE
    case BENCH_SCM: {
        std::string gsa[Nclock];

        for (unsigned int i=0; i<Nclock; i++)
        {
            Type t = ta[i];
            std::string scp = nn[i];

            std::ostringstream ss;
            for (unsigned int j=0; j<Nloops; j++) {
                ss << "(cog-new-node '"
                   << nameserver().getTypeName(t)
                   << " \"" << scp << "\")\n";
            }
            std::string lbl = GUILE_FUNB;
            lbl += std::to_string(i);
            std::string gs = memoize_or_compile(lbl, ss.str());
            gsa[i] = gs;
        }

        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            scm->eval_h(gsa[i]);
        return clock() - t_begin;
    }
#endif /* HAVE_GUILE */

#if HAVE_CYTHON
    case BENCH_PYTHON: {
        std::string psa[Nclock];

        for (unsigned int i=0; i<Nclock; i++)
        {
            Type t = ta[i];
            std::string scp = nn[i];

            std::ostringstream dss;
            for (unsigned int j=0; j<Nloops; j++) {
                if (memoize) dss << "    ";   // indentation
                dss << "aspace.add_node (" << t << ", \"" << scp << "\")\n";
            }

            std::string lbl = GUILE_FUNB;
            lbl += std::to_string(i);
            std::string ps = memoize_or_compile(lbl, dss.str());
            psa[i] = ps;
        }
        clock_t t_begin = clock();
        for (unsigned int i = 0; i < Nclock; ++i)
            pyev->eval(psa[i]);
        return clock() - t_begin;
    }
#endif /* HAVE_CYTHON */
    }

    return 0;
}

clock_t AtomSpaceBenchmark::makeRandomLinks()
{
    double p = randomGenerator->randdouble();
    Type ta[Nclock];
    HandleSeq og[Nclock];
    for (unsigned int i = 0; i<Nclock; i++)
    {
        Type t = defaultLinkType;
        if (p < chanceOfNonDefaultLink) t = randomType(LINK);
        ta[i] = t;

        size_t arity = (*poissonDistribution)(*randomGenerator);
        if (arity == 0) { ++arity; };

        // AtomSpace will throw if the context link has bad arity
        if (CONTEXT_LINK == t) arity = 2;

        HandleSeq outgoing;
        for (size_t j=0; j < arity; j++) {
            Handle h(getRandomHandle());
            outgoing.push_back(h);
        }
        og[i] = outgoing;
    }

    switch (testKind) {
#if HAVE_CYTHON
    case BENCH_PYTHON: {
        std::string psa[Nclock];
        for (unsigned int i = 0; i<Nclock; i++)
        {
            Type t = ta[i];
            const auto& outgoing = og[i];
            size_t arity = outgoing.size();

            OC_ASSERT(1 == Nloops, "Looping not supported for python");
            std::ostringstream dss;
            dss << "aspace.add_link (" << t << ", [";
            for (size_t j=0; j < arity; j++) {
                dss << "Atom( " << &(outgoing[j]) << ", aspace)";
                if (j < arity-1) dss  << ", ";
            }
            dss << " ] )\n";
            std::string ps = dss.str();
            psa[i] = ps;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            pyev->eval(psa[i]);
        return clock() - t_begin;
    }
#endif /* HAVE_CYTHON */

#if HAVE_GUILE
    case BENCH_SCM: {
        std::string gsa[Nclock];
        std::string symb = GUILE_SYMB;
        for (unsigned int i = 0; i<Nclock; i++)
        {
            Type t = ta[i];
            HandleSeq outgoing = og[i];
            size_t arity = outgoing.size();

            std::ostringstream ss;
            for (unsigned int j=0; j<Nloops; j++) {
                ss << "(cog-new-link '"
                   << nameserver().getTypeName(t);
                if (25 < arity) arity = 25;
                for (size_t k = 0; k < arity; k++) {
                    std::string bar = symb + std::to_string(i*Nloops + j);
                    bar += "-";
                    bar += std::to_string(k);
                    guile_define(bar, outgoing[k]);
                    ss << " " << bar;
                }
                ss << ")\n";
            }
            std::string lbl = GUILE_FUNB;
            lbl += std::to_string(i);
            std::string gs = memoize_or_compile(lbl, ss.str());
            gsa[i] = gs;
        }

        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            scm->eval_h(gsa[i]);
        return clock() - t_begin;
    }
#endif /* HAVE_GUILE */
    case BENCH_AS: {
        clock_t tAddLinkStart = clock();
        for (unsigned int i=0; i<Nclock; i++)
            asp->add_link(ta[i], std::move(og[i]));
        return clock() - tAddLinkStart;
    }}
    return 0;
}

void AtomSpaceBenchmark::buildAtomSpace(long atomspaceSize,
                                        float _percentLinks, bool display)
{
    BenchType saveKind = testKind;
#if HAVE_CYTHON
    if (testKind == BENCH_PYTHON)
       testKind = BENCH_AS;
#endif /* HAVE_CYTHON */
#if HAVE_GUILE
    if (testKind == BENCH_SCM)
       testKind = BENCH_AS;
#endif /* HAVE_GUILE */

    clock_t tStart = clock();
    if (display) {
        cout << "Building atomspace with " << atomspaceSize << " atoms (" <<
            _percentLinks*100.0 << "\% links)" << endl;
    }

    // Add nodes
    Nclock  = 5000;
    long nodeCount = atomspaceSize * (1.0f - _percentLinks) / Nclock;
    int i;
    if (display) cout << "Adding " << nodeCount*Nclock << " nodes ";
    int diff = nodeCount / PROGRESS_BAR_LENGTH;
    if (!diff) diff = 1;
    for (i=0; i<nodeCount; i++) {
        makeRandomNodes("");
        if (display && i % diff == 0) cerr << "." << flush;
    }

    /* Place all the atoms in the TLB too, so that we can later
     * pick some, randomly, just by picking a random int. */
    HandleSeq alln;
    asp->get_handles_by_type(alln, NODE, true);
    for (const Handle& h : alln)
        tlbuf.addAtom(h, TLB::INVALID_UUID);

    UUID_end = tlbuf.size() + UUID_PAD;

    // Add links
    if (display) cout << endl << "Adding " << atomspaceSize - nodeCount << " links " << flush;
    diff = ((atomspaceSize - nodeCount) / PROGRESS_BAR_LENGTH);
    if (!diff) diff = 1;
    for (; i < atomspaceSize/Nclock; i++) {
        makeRandomLinks();
        if (display && (i-nodeCount) % diff == 0) { cerr << "." << flush; }
    }

    if (display) {
        cout << endl;
        printf("Built atomspace, execution time: %.2fs\n",
             (double)(clock() - tStart)/CLOCKS_PER_SEC);
        cout << DIVIDER_LINE << endl;
    }

    /* Place all the links into the TLB */
    HandleSeq alli;
    asp->get_handles_by_type(alli, LINK, true);
    for (const Handle& h : alli)
        tlbuf.addAtom(h, TLB::INVALID_UUID);

    UUID_end = tlbuf.size() + UUID_PAD;
    testKind = saveKind;
}

timepair_t AtomSpaceBenchmark::bm_noop()
{
    // Benchmark clock overhead.
    int n[Nclock];
    for (unsigned int i=0; i<Nclock; i++)
    {
        n[i] = randomGenerator->randint(42);
    }

    clock_t t_begin = clock();
    int sum=0;
    // prevent compiler optimizer from optimizing away the loop.
    for (unsigned int i=0; i<Nclock; i++)
        sum += n[i];
    clock_t time_taken = clock() - t_begin;
    global += sum;
    return timepair_t(time_taken,0);
}

timepair_t AtomSpaceBenchmark::bm_addNode()
{
    //cout << "Benchmarking AtomSpace::addNode" << endl;
    return timepair_t(makeRandomNodes(""),0);
}

timepair_t AtomSpaceBenchmark::bm_addLink()
{
    //cout << "Benchmarking AtomSpace::addLink" << endl;
    return timepair_t(makeRandomLinks(),0);
}

timepair_t AtomSpaceBenchmark::bm_rmAtom()
{
    Handle hs[Nclock];
    for (unsigned int i=0; i<Nclock; i++)
    {
        Handle h = getRandomHandle();
        while (true)
        {
            h = getRandomHandle();

            // Can't remove something that has incoming links,
            // so find something that doesn't.
            while (0 < h->getIncomingSetSize()) {
                h = getRandomHandle();
            }
            bool uniq = true;
            for (unsigned int j=0; j<i; j++) {
                if (h == hs[j]) uniq = false;
            }
            if (uniq) break;
        }
        hs[i] = h;
    }

    switch (testKind) {
#if HAVE_CYTHON
    case BENCH_PYTHON: {
        std::string psa[Nclock];
        for (unsigned int i=0; i<Nclock; i++)
        {
            Handle h = hs[i];
            std::ostringstream dss;
            for (unsigned int i=0; i<Nloops; i++) {
                dss << "aspace.remove(Atom(" << &h << ", aspace))\n";
                h = getRandomHandle();
                // XXX FIXME --- this may have trouble finding anything if
                // Nloops is bigger than the number of links in the atomspace !
                while (0 < h->getIncomingSetSize()) {
                    h = getRandomHandle();
                }
            }
            std::string ps = dss.str();
            psa[i] = ps;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            pyev->eval(psa[i]);
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_CYTHON */
#if HAVE_GUILE
    case BENCH_SCM: {
        std::string gsa[Nclock];
        std::string symb = GUILE_SYMB;
        for (unsigned int i=0; i<Nclock; i++)
        {
            Handle h = hs[i];
            std::ostringstream ss;
            for (unsigned int j=0; j<Nloops; j++) {
                std::string bar = symb + std::to_string(i*Nloops + j);
                guile_define(bar, h);
                ss << "(cog-extract-recursive! " << bar << ")\n";
                h = getRandomHandle();
                // XXX FIXME --- this may have trouble finding
                // anything if Nloops is bigger than the number
                // of links in the atomspace !
                while (0 < h->getIncomingSetSize()) {
                    h = getRandomHandle();
                }
            }
            std::string lbl = GUILE_FUNB;
            lbl += std::to_string(i);
            std::string gs = memoize_or_compile(lbl, ss.str());
            gsa[i] = gs;
        }

        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++) {
            scm->eval(gsa[i]);
#ifdef DONT_IGNORE_ERRORS
            // There's a good chance were trying to delete something
            // that doesn't exist any more...
            if (scm->eval_error()) {
                printf("Caught error while evaluating %s\n", gsa[i].c_str());
                exit(1);
            }
#endif
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_GUILE */
    case BENCH_AS: {
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            asp->remove_atom(hs[i]);
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }}
    return timepair_t(0,0);
}

Handle AtomSpaceBenchmark::getRandomHandle()
{
    UUID ranu = UUID_begin + randomGenerator->randint(UUID_end-1-UUID_begin);
    Handle h(tlbuf.getAtom(ranu));
    // operator->() can return NULL when there's no atom for the uuid,
    // because the atom was deleted in a previous pass! Dohh!
    while (NULL == h.operator->()) {
        ranu = UUID_begin + randomGenerator->randint(UUID_end-1-UUID_begin);
        h = tlbuf.getAtom(ranu);
    }
    return h;
}

timepair_t AtomSpaceBenchmark::bm_getType()
{
    Handle hs[Nclock];
    for (unsigned int i=0; i<Nclock; i++)
        hs[i] = getRandomHandle();

    switch (testKind) {
#if HAVE_CYTHON
    case BENCH_PYTHON: {
        std::string psa[Nclock];
        for (unsigned int i=0; i<Nclock; i++)
        {
            Handle h = hs[i];
            std::ostringstream dss;
            for (unsigned int i=0; i<Nloops; i++) {
                dss << "type = Atom(" << &h << ", aspace)" << ".type\n";
                h = getRandomHandle();
            }
            std::string ps = dss.str();
            psa[i] = ps;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            pyev->eval(psa[i]);
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_CYTHON */

#if HAVE_GUILE
    case BENCH_SCM: {
        std::string gsa[Nclock];
        std::string symb = GUILE_SYMB;
        for (unsigned int i=0; i<Nclock; i++)
        {
            std::ostringstream ss;

            Handle h = hs[i];
            for (unsigned int j=0; j<Nloops; j++) {
                std::string bar = symb + std::to_string(i*Nloops + j);
                guile_define(bar, h);
                ss << "(cog-type " << bar << ")\n";
                h = getRandomHandle();
            }
            std::string lbl = GUILE_FUNB;
            lbl += std::to_string(i);
            std::string gs = memoize_or_compile(lbl, ss.str());
            gsa[i] = gs;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++) {
            scm->eval(gsa[i]);
            if (scm->eval_error()) {
                printf("Caught error while evaluating %s\n", gsa[i].c_str());
                exit(1);
            }
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_GUILE */

    case BENCH_AS:
    {
        clock_t t_begin = clock();
        // summing prevents the optimizer from optimizing away.
        int sum = 0;
        for (unsigned int i=0; i<Nclock; i++)
            sum += hs[i]->get_type();
        clock_t time_taken = clock() - t_begin;
        global += sum;
        return timepair_t(time_taken,0);
    }
    }
    return timepair_t(0,0);
}

timepair_t AtomSpaceBenchmark::bm_getTruthValue()
{
    Handle hs[Nclock];
    for (unsigned int i=0; i<Nclock; i++)
        hs[i] = getRandomHandle();

    switch (testKind) {
#if HAVE_CYTHON
    case BENCH_PYTHON: {
        OC_ASSERT(1 == Nloops, "Looping not supported for python");
        std::string psa[Nclock];
        for (unsigned int i=0; i<Nclock; i++)
        {
            Handle h = hs[i];
            std::ostringstream dss;
            dss << "tv = Atom(" << &h << ", aspace).tv\n";
            std::string ps = dss.str();
            psa[i] = ps;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            pyev->eval(psa[i]);
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_CYTHON */
#if HAVE_GUILE
    case BENCH_SCM: {
        std::string gsa[Nclock];
        for (unsigned int i=0; i<Nclock; i++)
        {
            std::ostringstream ss;

            Handle h = hs[i];
            std::string symb = GUILE_SYMB;

            for (unsigned int j=0; j<Nloops; j++) {
                std::string bar = symb + std::to_string(i*Nloops + j);
                guile_define(bar, h);
                ss << "(cog-tv " << bar << ")\n";
                h = getRandomHandle();
            }
            std::string lbl = GUILE_FUNB;
            lbl += std::to_string(i);
            std::string gs = memoize_or_compile(lbl, ss.str());
            gsa[i] = gs;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++) {
            scm->eval(gsa[i]);
            if (scm->eval_error()) {
                printf("Caught error while evaluating %s\n", gsa[i].c_str());
                exit(1);
            }
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_GUILE */
    case BENCH_AS:
    {
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            hs[i]->getTruthValue();
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
    }
    return timepair_t(0,0);
}

#ifdef ZMQ_EXPERIMENT
timepair_t AtomSpaceBenchmark::bm_getTruthValueZmq()
{
    Handle h = getRandomHandle();
    clock_t t_begin = clock();
    asp->getTVZmq(h);
    return clock() - t_begin;
}
#endif

timepair_t AtomSpaceBenchmark::bm_setTruthValue()
{
    Handle hs[Nclock];
    float strg[Nclock];
    float conf[Nclock];
    for (unsigned int i=0; i<Nclock; i++)
    {
        hs[i] = getRandomHandle();
        strg[i] = randomGenerator->randfloat();
        conf[i] = randomGenerator->randfloat();
    }

    switch (testKind) {
#if HAVE_CYTHON
    case BENCH_PYTHON: {
        OC_ASSERT(1 == Nloops, "Looping not supported for python");
        std::string psa[Nclock];
        for (unsigned int i=0; i<Nclock; i++)
        {
            Handle h = hs[i];
            float strength = strg[i];
            float cnf = conf[i];
            std::ostringstream dss;
            dss << "Atom(" << &h <<", aspace)"
                << ".truth_value(" << strength << ", " << cnf << ")\n";
            std::string ps = dss.str();
            psa[i] = ps;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            pyev->eval(psa[i]);
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_CYTHON */
#if HAVE_GUILE
    case BENCH_SCM: {
        std::string gsa[Nclock];
        for (unsigned int i=0; i<Nclock; i++)
        {
            std::ostringstream ss;

            Handle h = hs[i];
            float strength = strg[i];
            float cnf = conf[i];
            std::string symb = GUILE_SYMB;

            for (unsigned int j=0; j<Nloops; j++) {
                std::string bar = symb + std::to_string(i*Nloops + j);
                guile_define(bar, h);
                ss << "(cog-set-tv! " << bar
                   << "   (cog-new-stv " << strength << " " << cnf << ")"
                   << ")\n";
                h = getRandomHandle();
                strength = randomGenerator->randfloat();
                cnf = randomGenerator->randfloat();
            }
            std::string lbl = GUILE_FUNB;
            lbl += std::to_string(i);
            std::string gs = memoize_or_compile(lbl, ss.str());
            gsa[i] = gs;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++) {
            scm->eval(gsa[i]);
            if (scm->eval_error()) {
                printf("Caught error while evaluating %s\n", gsa[i].c_str());
                exit(1);
            }
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_GUILE */
    case BENCH_AS:
    {
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
        {
            TruthValuePtr stv(SimpleTruthValue::createTV(strg[i], conf[i]));
            hs[i]->setTruthValue(stv);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
    }
    return timepair_t(0,0);
}

timepair_t AtomSpaceBenchmark::bm_getIncomingSet()
{
    Handle hs[Nclock];
    for (unsigned int i=0; i<Nclock; i++)
        hs[i] = getRandomHandle();

    switch (testKind) {
#if HAVE_CYTHON
    case BENCH_PYTHON: {
        OC_ASSERT(1 == Nloops, "Looping not supported for python");
        std::string psa[Nclock];
        for (unsigned int i=0; i<Nclock; i++)
        {
            Handle h = hs[i];
            std::ostringstream dss;
            dss << "incoming = Atom(" << &h << ", aspace).incoming\n";
            std::string ps = dss.str();
            psa[i] = ps;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            pyev->eval(psa[i]);
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_CYTHON */
#if HAVE_GUILE
    case BENCH_SCM: {
        std::string gsa[Nclock];
        for (unsigned int i=0; i<Nclock; i++)
        {
            std::ostringstream ss;

            Handle h = hs[i];
            std::string symb = GUILE_SYMB;

            for (unsigned int j=0; j<Nloops; j++) {
                std::string bar = symb + std::to_string(i*Nloops + j);
                guile_define(bar, h);
                ss << "(cog-incoming-set " << bar << ")\n";
                h = getRandomHandle();
            }
            std::string lbl = GUILE_FUNB;
            lbl += std::to_string(i);
            std::string gs = memoize_or_compile(lbl, ss.str());
            gsa[i] = gs;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++) {
            scm->eval(gsa[i]);
            if (scm->eval_error()) {
                printf("Caught error while evaluating %s\n", gsa[i].c_str());
                exit(1);
            }
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_GUILE */
    case BENCH_AS:
    {
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            hs[i]->getIncomingSet();
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
    }
    return timepair_t(0,0);
}

timepair_t AtomSpaceBenchmark::bm_getIncomingSetSize()
{
    Handle hs[Nclock];
    for (unsigned int i=0; i<Nclock; i++)
        hs[i] = getRandomHandle();

    switch (testKind) {
#if HAVE_CYTHON
    case BENCH_PYTHON: {
        return timepair_t(0,0);
    }
#endif /* HAVE_CYTHON */
#if HAVE_GUILE
    case BENCH_SCM: {
        return timepair_t(0,0);
    }
#endif /* HAVE_GUILE */
    case BENCH_AS:
    {
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            hs[i]->getIncomingSetSize();
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
    }
    return timepair_t(0,0);
}

// How long does it take to cast?
timepair_t AtomSpaceBenchmark::bm_pointerCast()
{
    Handle hs[Nclock];
    for (unsigned int i=0; i<Nclock; i++)
        hs[i] = getRandomHandle();

    switch (testKind) {
#if HAVE_CYTHON
    case BENCH_PYTHON: {
        return timepair_t(0,0);
    }
#endif /* HAVE_CYTHON */
#if HAVE_GUILE
    case BENCH_SCM: {
        return timepair_t(0,0);
    }
#endif /* HAVE_GUILE */
    case BENCH_AS:
    {
        // Summing prevents the optimizer from optimizing away.
        // We want to measure how long it takes to perform a cast.
        // To avoid the optimizer from playing tricks, we hav to do
        // something with the resulting pointer.  We already know that
        // get_type() is very fast -- a method call, so we treat that as
        // a kind-of no-op.
        int sum = 0;
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
        {
#define MEASURE_LINKS
#ifdef MEASURE_LINKS
            LinkPtr l(LinkCast(hs[i]));
            if (l)
               sum += l->get_type();
#else
            NodePtr n(NodeCast(hs[i]));
            if (n)
               sum += n->get_type();
#endif
        }
        clock_t time_taken = clock() - t_begin;
        global += sum;
        return timepair_t(time_taken,0);
    }
    }
    return timepair_t(0,0);
}

timepair_t AtomSpaceBenchmark::bm_getOutgoingSet()
{
    Handle hs[Nclock];
    for (unsigned int i=0; i<Nclock; i++)
        hs[i] = getRandomHandle();

    switch (testKind) {
#if HAVE_CYTHON
    case BENCH_PYTHON: {
        OC_ASSERT(1 == Nloops, "Looping not supported for python");
        std::string psa[Nclock];
        for (unsigned int i=0; i<Nclock; i++)
        {
            Handle h = hs[i];
            std::ostringstream dss;
            dss << "out = Atom(" << &h << ", aspace).out\n";
            std::string ps = dss.str();
            psa[i] = ps;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
            pyev->eval(psa[i]);
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_CYTHON */
#if HAVE_GUILE
    case BENCH_SCM: {
        std::string gsa[Nclock];
        for (unsigned int i=0; i<Nclock; i++)
        {
            std::ostringstream ss;

            Handle h = hs[i];
            std::string symb = GUILE_SYMB;

            for (unsigned int j=0; j<Nloops; j++) {
                std::string bar = symb + std::to_string(i*Nloops + j);
                guile_define(bar, h);
                ss << "(cog-outgoing-set " << bar << ")\n";
                h = getRandomHandle();
            }
            std::string lbl = GUILE_FUNB;
            lbl += std::to_string(i);
            std::string gs = memoize_or_compile(lbl, ss.str());
            gsa[i] = gs;
        }
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++) {
            scm->eval(gsa[i]);
            if (scm->eval_error()) {
                printf("Caught error while evaluating %s\n", gsa[i].c_str());
                exit(1);
            }
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
#endif /* HAVE_GUILE */
    case BENCH_AS:
    {
        clock_t t_begin = clock();
        for (unsigned int i=0; i<Nclock; i++)
        {
            if (hs[i]->is_link())
                hs[i]->getOutgoingSet();
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }
    }
    return timepair_t(0,0);
}

timepair_t AtomSpaceBenchmark::bm_getHandlesByType()
{
    Type t = randomType(ATOM);
    switch (testKind) {
#if HAVE_CYTHON
    case BENCH_PYTHON: {
        OC_ASSERT(1 == Nloops, "Looping not supported for python");
        std::ostringstream dss;
        dss << "aspace.get_atoms_by_type(" << t << ", True)\n";
        std::string ps = dss.str();
        clock_t t_begin = clock();
        pyev->eval(ps);
        clock_t time_taken = clock() - t_begin;
        return timepair_t(Nclock*time_taken,0);
    }
#endif /* HAVE_CYTHON */
#if HAVE_GUILE
    case BENCH_SCM: {
        // Currently not expose in the SCM API
        return timepair_t(0,0);
    }
#endif /* HAVE_GUILE */
    case BENCH_AS: {
        HandleSeq results;
        clock_t t_begin = clock();
        asp->get_handles_by_type(results, t, true);
        clock_t time_taken = clock() - t_begin;
        return timepair_t(Nclock*time_taken,0);
    }}
    return timepair_t(0,0);
}

// ================================================================
// ================================================================
// ================================================================

timepair_t AtomSpaceBenchmark::bm_push_back()
{
    Handle ha = getRandomHandle();
    Handle hb = getRandomHandle();
    Handle hc = getRandomHandle();
    Handle hd = getRandomHandle();

    if (1 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            // HandleSeq oset;
            HandleSeq oset;
            oset.push_back(ha);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (2 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            // HandleSeq oset;
            HandleSeq oset;
            oset.push_back(ha);
            oset.push_back(hb);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (3 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            // HandleSeq oset;
            HandleSeq oset;
            oset.push_back(ha);
            oset.push_back(hb);
            oset.push_back(hc);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (4 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            // HandleSeq oset;
            HandleSeq oset;
            oset.push_back(ha);
            oset.push_back(hb);
            oset.push_back(hc);
            oset.push_back(hd);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    return timepair_t(0,0);
}


timepair_t AtomSpaceBenchmark::bm_push_back_reserve()
{
    Handle ha = getRandomHandle();
    Handle hb = getRandomHandle();
    Handle hc = getRandomHandle();
    Handle hd = getRandomHandle();

    if (1 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            // HandleSeq oset;
            HandleSeq oset;
            oset.reserve(Nreserve);
            oset.push_back(ha);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (2 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            // HandleSeq oset;
            HandleSeq oset;
            oset.reserve(Nreserve);
            oset.push_back(ha);
            oset.push_back(hb);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (3 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            // HandleSeq oset;
            HandleSeq oset;
            oset.reserve(Nreserve);
            oset.push_back(ha);
            oset.push_back(hb);
            oset.push_back(hc);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (4 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            // HandleSeq oset;
            HandleSeq oset;
            oset.reserve(Nreserve);
            oset.push_back(ha);
            oset.push_back(hb);
            oset.push_back(hc);
            oset.push_back(hd);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    return timepair_t(0,0);
}

timepair_t AtomSpaceBenchmark::bm_emplace_back()
{
    Handle ha = getRandomHandle();
    Handle hb = getRandomHandle();
    Handle hc = getRandomHandle();
    Handle hd = getRandomHandle();

    if (1 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset;
            oset.emplace_back(ha);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (2 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset;
            oset.emplace_back(ha);
            oset.emplace_back(hb);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (3 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset;
            oset.emplace_back(ha);
            oset.emplace_back(hb);
            oset.emplace_back(hc);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (4 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset;
            oset.emplace_back(ha);
            oset.emplace_back(hb);
            oset.emplace_back(hc);
            oset.emplace_back(hd);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    return timepair_t(0,0);
}

timepair_t AtomSpaceBenchmark::bm_emplace_back_reserve()
{
    Handle ha = getRandomHandle();
    Handle hb = getRandomHandle();
    Handle hc = getRandomHandle();
    Handle hd = getRandomHandle();

    if (1 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset;
            oset.reserve(Nreserve);
            oset.emplace_back(ha);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (2 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset;
            oset.reserve(Nreserve);
            oset.emplace_back(ha);
            oset.emplace_back(hb);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (3 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset;
            oset.reserve(Nreserve);
            oset.emplace_back(ha);
            oset.emplace_back(hb);
            oset.emplace_back(hc);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (4 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset;
            oset.reserve(Nreserve);
            oset.emplace_back(ha);
            oset.emplace_back(hb);
            oset.emplace_back(hc);
            oset.emplace_back(hd);
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    return timepair_t(0,0);
}

timepair_t AtomSpaceBenchmark::bm_reserve()
{
    Handle ha = getRandomHandle();
    Handle hb = getRandomHandle();
    Handle hc = getRandomHandle();
    Handle hd = getRandomHandle();

    if (1 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset(Nreserve);
            oset[0] = ha;
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (2 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset(Nreserve);
            oset[0] = ha;
            oset[1] = hb;
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (3 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset(Nreserve);
            oset[0] = ha;
            oset[1] = hb;
            oset[2] = hc;
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    if (4 == Nreserve)
    {
        clock_t t_begin = clock();
        for (unsigned int i = 0; i<Nclock; i++)
        {
            HandleSeq oset(Nreserve);
            oset[0] = ha;
            oset[1] = hb;
            oset[2] = hc;
            oset[3] = hd;
        }
        clock_t time_taken = clock() - t_begin;
        return timepair_t(time_taken,0);
    }

    return timepair_t(0,0);
}

// ================================================================

AtomSpaceBenchmark::TimeStats::TimeStats(
        const std::vector<record_t>& records)
{
    double sum = 0;
    t_min = 1 << 30;
    t_max = 0;
    for (record_t record : records) {
        sum += get<1>(record);
        if (get<1>(record) > t_max) t_max = get<1>(record);
        if (get<1>(record) < t_min) t_min = get<1>(record);
    }
    t_total = sum;
    t_N = records.size();
    t_mean = sum / t_N;
    sum = 0.0;
    for (record_t record : records) {
        clock_t value = (get<1>(record) - t_mean);
        sum += (value*value);
    }
    t_std = sqrt(sum/(t_N-1));
}

void AtomSpaceBenchmark::TimeStats::print()
{
    cout << "Per operation stats, in CPU clock ticks: " << endl;
    cout << "  N: " << t_N << endl;
    cout << "  mean: " << t_mean << endl;
    cout << "  min: " << t_min << endl;
    cout << "  max: " << t_max << endl;
    cout << "  std: " << t_std << endl;
}

void AtomSpaceBenchmark::recordToFile(std::ofstream& myfile, record_t record) const
{
    myfile << tuples::set_open(' ');
    myfile << tuples::set_close(' ');
    myfile << tuples::set_delimiter(',');
    myfile << record;
    myfile << "," << (float) get<1>(record) / CLOCKS_PER_SEC << endl;
}

}
