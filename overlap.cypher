

// === Start === 
MATCH (c:DECISION_CASE)-[]->(i)
WITH {item:id(c), categories: collect(id(i))} AS simiData
WITH collect(simiData) AS data

CALL algo.similarity.overlap.stream(data, {
    topK:1, similarityCutoff: 0.1
})
YIELD item1, item2, count1, count2, similarity

RETURN algo.asNode(item1).name AS A, 
       algo.asNode(item2).name AS B, 
       similarity
ORDER BY similarity DESC
// === End ===


// === Start === 
// Create list of nodes ids of cases with any type of relationship
MATCH (c:DECISION_CASE)-[]->(i)
WITH {item:id(c), categories: collect(id(i))} AS simiData
WITH collect(simiData) AS data

CALL algo.similarity.overlap(data, {
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


CALL algo.louvain.stream("DECISION_CASE", "NARROWER_THAN", {includeIntermediateCommunities: true})
YIELD nodeId, communities
WITH algo.asNode(nodeId) AS case, communities
SET case.communities = communities


MATCH (c:DECISION_CASE)
RETURN c.communities[-1] AS community, collect(c.name) AS cases, count(*) AS size 
ORDER BY community 


MATCH ()-[r:NARROWER_THAN]-() 
DELETE r