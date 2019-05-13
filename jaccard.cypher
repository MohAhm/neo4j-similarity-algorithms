
// === Start === 
// Create list of nodes ids of cases with any type of relationship
MATCH (c:DECISION_CASE)-[*]->(i)
WITH {item:id(c), categories: collect(id(i))} as simiData
WITH collect(simiData) as data
// Stream similar cases 
CALL algo.similarity.jaccard.stream(data, {
    topK:1, similarityCutoff: 0.1
})
YIELD item1, item2, count1, count2, similarity
// Look up nodes by node id
WITH algo.asNode(item1) AS c1, 
     algo.asNode(item2) AS c2, 
     similarity
RETURN c1.name, c2.name, similarity
ORDER BY similarity DESC
// === End ===



// === Start === 
// Create list of nodes ids of cases with any type of relationship
MATCH (c:DECISION_CASE)-[*]->(i)
WITH {item:id(c), categories: collect(id(i))} AS simiData
WITH collect(simiData) AS data
// Store similar cases together 
CALL algo.similarity.jaccard(data, {
    topK:1, 
    similarityCutoff: 0.1, 
    write:true,
    writeRelationshipType: 'JACCARD_SIMILAR'
})
YIELD nodes, similarityPairs, write, writeRelationshipType, writeProperty, 
            min, max, mean, stdDev, 
            p25, p50, p75, p90, p95, p99, p999, p100

RETURN nodes, similarityPairs, write, writeRelationshipType, writeProperty, 
            min, max, mean, p95
// === End === 



// === Start ===
// Chaining algorithms: Jaccard + Louvain
CALL algo.louvain.stream(
    'MATCH (c:DECISION_CASE) RETURN id(c) as id', 
    'MATCH (c:DECISION_CASE)-[*]->(i)
     WITH {item:id(c), categories: collect(id(i))} AS simiData
     WITH collect(simiData) AS data
     CALL algo.similarity.jaccard.stream(data, {
         topK:1, similarityCutoff: 0.1, write:false
     })
     YIELD item1, item2, similarity
     RETURN item1 AS source, item2 AS target', 
    {graph: 'cypher'})
YIELD nodeId, community

WITH algo.asNode(nodeId) AS cases, community
RETURN cases.name, community
ORDER BY community
// === End === 



// === Testing/Reviewing === 

MATCH path = (c1:DECISION_CASE)-[:SIMILAR]->(c2)
RETURN path
LIMIT 4


MATCH path = (c1:DECISION_CASE)-[:SIMILAR]->(c2)-[r]->(i)
WHERE type(r) <> "SIMILAR"
RETURN path
LIMIT 30


// Delete the relationship
MATCH ()-[r:JACCARD_SIMILAR]-() 
DELETE r