
// === Start === 
MATCH (c:DECISION_CASE)
OPTIONAL MATCH (c)-[r]->(i)
WITH {item:id(c), weights: collect(coalesce(id(r), algo.NaN()))} as simiData
WITH collect(simiData) as data
CALL algo.similarity.cosine.stream(data, {
    topK:10
})
YIELD item1, item2, count1, count2, similarity
RETURN algo.asNode(item1).name AS from, algo.asNode(item2).name AS to, similarity
ORDER BY similarity DESC
// === End ===


// === Start === 
MATCH (c:DECISION_CASE)
OPTIONAL MATCH (c)-[r]->(i)
WITH {item:id(c), weights: collect(coalesce(id(r), algo.NaN()))} as simiData
WITH collect(simiData) as data
// Store similar cases together 
CALL algo.similarity.cosine(data, {
    topK:10, write:true
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
         topK:10, write:false
     })
     YIELD item1, item2, similarity
     RETURN item1 AS source, item2 AS target', 
    {graph: 'cypher'})
YIELD nodeId, community

WITH algo.asNode(nodeId) AS cases, community
RETURN cases.name, community
ORDER BY community
// === End ===