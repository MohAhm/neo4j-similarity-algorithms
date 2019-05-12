
// ================  Similarity of all pairs using Streaming procedure ================ 
MATCH (c:DECISION_CASE)-[*]->(i)
WITH {item:id(c), categories: collect(id(i))} as userData
WITH collect(userData) as data

CALL algo.similarity.jaccard.stream(data)
YIELD item1, item2, count1, count2, similarity

// Look up nodes by node id
WITH algo.asNode(item1) AS c1, 
     algo.asNode(item2) AS c2, 
     similarity
RETURN c1.name, c2.name, similarity
ORDER BY similarity DESC
// ================  END ================ 