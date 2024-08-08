package com.jwt;

import lombok.extern.slf4j.Slf4j;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Slf4j
public class Practice {
    public static void main(String[] args) {
        LinkedList<Integer> linkedList = new LinkedList<>(Arrays.asList(10, 20, 30, 40, 50));
        System.out.println("Original LinkedList: " + linkedList);

        linkedList.addFirst(5);
        linkedList.addLast(55);
        System.out.println("After adding elements: " + linkedList);

        linkedList.removeFirst();
        linkedList.removeLast();
        System.out.println("After removing elements: " + linkedList);

        System.out.println("Element at index 2: " + linkedList.get(2));

        ArrayList<String> arrayList = new ArrayList<>(Arrays.asList("Red", "Green", "Blue", "Yellow"));
        System.out.println("Original ArrayList: " + arrayList);

        arrayList.set(2, "Purple");
        System.out.println("After replacing Blue with Purple: " + arrayList);

        arrayList.sort(Comparator.naturalOrder());
        System.out.println("Sorted ArrayList: " + arrayList);

        HashSet<String> hashSet = new HashSet<>(Arrays.asList("Banana", "Apple", "Mango", "Orange", "Banana"));
        System.out.println("Original HashSet (no duplicates): " + hashSet);

        System.out.println("Contains 'Apple': " + hashSet.contains("Apple"));

        hashSet.add("Grapes");
        hashSet.remove("Mango");
        System.out.println("After adding Grapes and removing Mango: " + hashSet);

        TreeSet<Integer> treeSet = new TreeSet<>(Arrays.asList(10, 20, 5, 15, 25, 10));
        System.out.println("Original TreeSet (sorted): " + treeSet);

        SortedSet<Integer> subset = treeSet.subSet(10, 20);
        System.out.println("Subset from 10 (inclusive) to 20 (exclusive): " + subset);

        HashMap<Integer, String> hashMap = new HashMap<>();
        hashMap.put(1, "One");
        hashMap.put(2, "Two");
        hashMap.put(3, "Three");
        hashMap.put(4, "Four");
        System.out.println("Original HashMap: " + hashMap);

        System.out.println("Iterating over HashMap:");
        for (Map.Entry<Integer, String> entry : hashMap.entrySet()) {
            System.out.println(entry.getKey() + " -> " + entry.getValue());
        }

        hashMap.replace(3, "Three (Updated)");
        System.out.println("After replacing the value for key 3: " + hashMap);

        TreeMap<String, Integer> treeMap = new TreeMap<>();
        treeMap.put("Bob", 85);
        treeMap.put("Alice", 92);
        treeMap.put("Charlie", 78);
        treeMap.put("David", 95);
        System.out.println("Original TreeMap (sorted by keys): " + treeMap);

        System.out.println("First entry: " + treeMap.firstEntry());
        System.out.println("Last entry: " + treeMap.lastEntry());

        System.out.println("Lower entry than 'Charlie': " + treeMap.lowerEntry("Charlie"));
        System.out.println("Higher entry than 'Charlie': " + treeMap.higherEntry("Charlie"));

        List<String> words = Arrays.asList("apple", "banana", "apricot", "cherry", "avocado");

        List<String> filteredWords = words.stream()
                .filter(word -> word.startsWith("a"))
                .map(String::toUpperCase)
                .sorted()
                .collect(Collectors.toList());
        System.out.println("Filtered and transformed words: " + filteredWords);

        Map<Integer, List<String>> groupedByLength = words.stream()
                .collect(Collectors.groupingBy(String::length));
        System.out.println("Grouped by word length: " + groupedByLength);

        String joinedWords = words.stream()
                .collect(Collectors.joining(", "));
        System.out.println("Joined words: " + joinedWords);

        ConcurrentHashMap<String, Integer> concurrentHashMap = new ConcurrentHashMap<>();
        concurrentHashMap.put("Java", 100);
        concurrentHashMap.put("Python", 80);
        concurrentHashMap.put("JavaScript", 90);
        System.out.println("Original ConcurrentHashMap: " + concurrentHashMap);

        concurrentHashMap.computeIfAbsent("C++", key -> 75);
        System.out.println("After computeIfAbsent for 'C++': " + concurrentHashMap);

        concurrentHashMap.computeIfPresent("Java", (key, value) -> value + 10);
        System.out.println("After computeIfPresent for 'Java': " + concurrentHashMap);

        System.out.println("Iterating over ConcurrentHashMap:");
        concurrentHashMap.forEach((key, value) -> {
            System.out.println(key + " -> " + value);
        });
    }
}
