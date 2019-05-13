
// #1
// === Start === 
// Louvain algorithm
CALL algo.louvain.stream('DECISION_CASE', 'SIMILAR', { iterations: 10 })
YIELD nodeId, community

WITH algo.asNode(nodeId) AS cases, community
RETURN cases.name, community
ORDER BY community
// === End ===


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
RETURN c.communities[-1] AS community, collect(c.name) AS cases
ORDER BY size(cases) DESC

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
// In our case every node is connected so there is only one community
// Therefore, this algorithm is not usefull
// === End ===


// === Start === 
// Strongly Connected Components algorithm
CALL algo.scc.stream('DECISION_CASE', 'SIMILAR', {})
YIELD nodeId, partition

WITH algo.asNode(nodeId) AS cases, partition
RETURN cases.name, partition
// "A strongly connected component only exists if there are relationships between nodes in both direction."
// Not usefull
// === End ===


// === Start === 
// Triangle Counting
CALL algo.triangle.stream('DECISION_CASE','SIMILAR')
YIELD nodeA,nodeB,nodeC

RETURN  algo.asNode(nodeA).name AS nodeA, 
        algo.asNode(nodeB).name AS nodeB,
        algo.asNode(nodeC).name AS nodeC
// Not usefull, each node is contained in some triangle
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
