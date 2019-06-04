
// #1
// === Start === 
// Louvain algorithm
CALL algo.louvain.stream('DECISION_CASE', 'SIMILAR', { iterations: 10 })
YIELD nodeId, community

WITH algo.asNode(nodeId) AS cases, community
RETURN cases.name, community
ORDER BY community
// === End ===

CALL algo.louvain("DECISION_CASE", "SIMILAR")

// === Start === 
// Louvain Modularity
CALL algo.louvain.stream('DECISION_CASE', 'SIMILAR', {includeIntermediateCommunities: true})
YIELD nodeId, communities

WITH algo.asNode(nodeId) AS case, communities
RETURN case.name, communities
ORDER BY communities


CALL algo.louvain.stream("DECISION_CASE", "SIMILAR", {includeIntermediateCommunities: true})
YIELD nodeId, communities
WITH algo.asNode(nodeId) AS case, communities
SET case.communities = communities


MATCH (c:DECISION_CASE)
RETURN c.communities[-1] AS community, collect(c.name) AS cases, count(*) AS size 
ORDER BY community 

MATCH (c:DECISION_CASE)
RETURN c.communities[0] AS community, collect(c.name) AS cases
ORDER BY size(cases) DESC
// === End ===



// #2
// === Start === 
// Label Propagation algorithm
CALL algo.labelPropagation.stream('DECISION_CASE','SIMILAR', {})
YIELD nodeId, label

RETURN label, 
       collect(algo.getNodeById(nodeId).name) AS categories, 
       count(*) as size 
ORDER BY size
// === End ===


// === Start === 
// Connected Components algorithm
CALL algo.unionFind.stream('DECISION_CASE', 'SIMILAR', {})
YIELD nodeId, setId

WITH algo.asNode(nodeId) AS case, setId
RETURN case.name, setId
ORDER BY setId
// === End ===


// === Start === 
// Strongly Connected Components algorithm
CALL algo.scc.stream('DECISION_CASE', 'SIMILAR', {})
YIELD nodeId, partition

WITH partition, algo.asNode(nodeId) AS cases
RETURN partition, cases.name
// === End ===


// === Start === 
// Triangle Counting
CALL algo.triangle.stream('DECISION_CASE','SIMILAR')
YIELD nodeA,nodeB,nodeC

RETURN  algo.asNode(nodeA).name AS nodeA, 
        algo.asNode(nodeB).name AS nodeB,
        algo.asNode(nodeC).name AS nodeC
// === End ===


// #3
// === Start === 
// Clustering Coefficient algorithm
CALL algo.triangleCount.stream('DECISION_CASE', 'SIMILAR', {})
YIELD nodeId, triangles, coefficient

RETURN algo.asNode(nodeId).name AS case, triangles, coefficient
ORDER BY coefficient DESC
// ORDER BY triangles DESC
// === End ===
