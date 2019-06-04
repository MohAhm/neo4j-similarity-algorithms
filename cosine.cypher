
// similarity: number of relationship with nodes that thye have in common
MATCH (c1:DECISION_CASE {name: 'Case 74'})-[r1]->(i)<-[r2]-(c2:DECISION_CASE {name: 'Case 73'})
RETURN i, c1, c2
// RETURN i, c1, c2

// === Start === 
MATCH (c:DECISION_CASE)-[r]->()
WITH {item:id(c), weights: collect(id(r))} AS simiData
WITH collect(simiData) AS data
CALL algo.similarity.cosine.stream(data, {
    topK:1, similarityCutoff: 0.1
})
YIELD item1, item2, count1, count2, similarity
RETURN algo.asNode(item1).name AS A, 
       algo.asNode(item2).name AS B, 
       similarity
ORDER BY similarity DESC

LIMIT 3
// === End ===


// === Start === 
MATCH (c:DECISION_CASE)-[r]->()
WITH {item:id(c), weights: collect(id(r))} as simiData
WITH collect(simiData) as data
// Store similar cases together 
CALL algo.similarity.cosine(data, {
    topK:1, 
    similarityCutoff: 0.1, 
    write:true
})
YIELD nodes, similarityPairs, write, writeRelationshipType, writeProperty, 
            min, max, mean, stdDev, 
            p25, p50, p75, p90, p95, p99, p999, p100

RETURN nodes, similarityPairs, write, writeRelationshipType, writeProperty, 
            min, max, mean, p95
// === End === 


// === Start ===
// Chaining algorithms: Cosine + Louvain
CALL algo.louvain.stream(
    'MATCH (c:DECISION_CASE) RETURN id(c) as id', 
    'MATCH (c:DECISION_CASE)
     OPTIONAL MATCH (c)-[r]->(i)
     WITH {item:id(c), weights: collect(coalesce(id(r), algo.NaN()))} as simiData
     WITH collect(simiData) AS data
     CALL algo.similarity.cosine.stream(data, {
         topK:1, write:false
     })
     YIELD item1, item2, similarity
     RETURN item1 AS source, item2 AS target', 
    {graph: 'cypher'})
YIELD nodeId, community

WITH algo.asNode(nodeId) AS cases, community
RETURN cases.name, community
ORDER BY community
// === End ===

