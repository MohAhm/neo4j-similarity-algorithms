

// === Start === 
MATCH (c:DECISION_CASE)-[r]->()
WITH {item:id(c), weights: collect(id(r))} AS simiData
WITH collect(simiData) AS data
CALL algo.similarity.euclidean.stream(data, {topK:1})
YIELD item1, item2, count1, count2, similarity
RETURN  algo.asNode(item1).name AS A, 
        algo.asNode(item2).name AS B, 
        similarity
ORDER BY similarity
// === End ===


// === Start === 
MATCH (c:DECISION_CASE)-[r]->()
WITH {item:id(c), weights: collect(id(r))} as simiData
WITH collect(simiData) as data
CALL algo.similarity.euclidean(data, {
    topK: 1, 
    write:true
})

YIELD nodes, similarityPairs, write, writeRelationshipType, writeProperty, 
            min, max, mean, stdDev, 
            p25, p50, p75, p90, p95, p99, p999, p100

RETURN nodes, similarityPairs, write, writeRelationshipType, writeProperty, 
            min, max, mean, p95
// === End === 

