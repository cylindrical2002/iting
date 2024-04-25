package org.cylindrical.iting;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.cylindrical.iting.grammar.ArithmeticLexer;
import org.cylindrical.iting.grammar.ArithmeticParser;
import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.QueryConfig;
import org.neo4j.driver.RoutingControl;

import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class Main {
    public static void main(String[] args) throws Exception {
        String expression = "3 + 5 * 2";
        CharStream input = CharStreams.fromString(expression);
        ArithmeticLexer lexer = new ArithmeticLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        ArithmeticParser parser = new ArithmeticParser(tokens);
        ParseTree tree = parser.expr();
        System.out.println(tree.toStringTree(parser));

        final String dbUri = "neo4j://localhost:7687";
        final String dbUser = "neo4j";
        final String dbPassword = "cdq1230L";

        try (var driver = GraphDatabase.driver(dbUri, AuthTokens.basic(dbUser, dbPassword))) {

            List<Map> people = List.of(
                    Map.of("name", "Alice", "age", 42, "friends", List.of("Bob", "Peter", "Anna")),
                    Map.of("name", "Bob", "age", 19),
                    Map.of("name", "Peter", "age", 50),
                    Map.of("name", "Anna", "age", 30)
            );

            try {

                //Create some nodes
                people.forEach(person -> {
                    var result = driver.executableQuery("CREATE (p:Person {name: $person.name, age: $person.age})")
                            .withConfig(QueryConfig.builder().withDatabase("neo4j").build())
                            .withParameters(Map.of("person", person))
                            .execute();
                });

                // Create some relationships
                people.forEach(person -> {
                    if (person.containsKey("friends")) {
                        var result = driver.executableQuery("""
                                        MATCH (p:Person {name: $person.name})
                                        UNWIND $person.friends AS friend_name
                                        MATCH (friend:Person {name: friend_name})
                                        CREATE (p)-[:KNOWS]->(friend)
                                         """)
                                .withConfig(QueryConfig.builder().withDatabase("neo4j").build())
                                .withParameters(Map.of("person", person))
                                .execute();
                    }
                });

                // Retrieve Alice's friends who are under 40
                var result = driver.executableQuery("""
                                MATCH (p:Person {name: $name})-[:KNOWS]-(friend:Person)
                                WHERE friend.age < $age
                                RETURN friend
                                 """)
                        .withConfig(QueryConfig.builder()
                                .withDatabase("neo4j")
                                .withRouting(RoutingControl.READ)
                                .build())
                        .withParameters(Map.of("name", "Alice", "age", 40))
                        .execute();

                // Loop through results and do something with them
                result.records().forEach(r -> {
                    System.out.println(r);
                });

                // Summary information
                System.out.printf("The query %s returned %d records in %d ms.%n",
                        result.summary().query(), result.records().size(),
                        result.summary().resultAvailableAfter(TimeUnit.MILLISECONDS));

            } catch (Exception e) {
                System.out.println(e.getMessage());
                System.exit(1);
            }
        }
    }
}
