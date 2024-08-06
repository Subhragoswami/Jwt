package com.jwt;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class Test {

    // Bubble Sort
    public static void bubbleSort(int[] array) {
        int n = array.length;
        for (int i = 0; i < n - 1; i++) {
            for (int j = 0; j < n - 1 - i; j++) {
                if (array[j] > array[j + 1]) {
                    int temp = array[j];
                    array[j] = array[j + 1];
                    array[j + 1] = temp;
                }
            }
        }
    }

    // Insertion Sort
    public static void insertionSort(int[] array) {
        int n = array.length;
        for (int i = 1; i < n; ++i) {
            int key = array[i];
            int j = i - 1;
            while (j >= 0 && array[j] > key) {
                array[j + 1] = array[j];
                j = j - 1;
            }
            array[j + 1] = key;
        }
    }

    // Quick Sort
    public static void quickSort(int[] array, int low, int high) {
        if (low < high) {
            int pi = partition(array, low, high);
            quickSort(array, low, pi - 1);
            quickSort(array, pi + 1, high);
        }
    }

    private static int partition(int[] array, int low, int high) {
        int pivot = array[high];
        int i = (low - 1);
        for (int j = low; j < high; j++) {
            if (array[j] < pivot) {
                i++;
                int temp = array[i];
                array[i] = array[j];
                array[j] = temp;
            }
        }
        int temp = array[i + 1];
        array[i + 1] = array[high];
        array[high] = temp;
        return i + 1;
    }

    // Binary Search
    public static int binarySearch(int[] array, int x) {
        int left = 0, right = array.length - 1;
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (array[mid] == x)
                return mid;
            if (array[mid] < x)
                left = mid + 1;
            else
                right = mid - 1;
        }
        return -1;
    }

    // Linear Search
    public static int linearSearch(int[] array, int x) {
        for (int i = 0; i < array.length; i++) {
            if (array[i] == x)
                return i;
        }
        return -1;
    }

    public static void main(String[] args) {
        int[] array1 = {64, 34, 25, 12, 22, 11, 90};
        int[] array2 = {12, 11, 13, 5, 6};
        int[] array3 = {10, 7, 8, 9, 1, 5};
        int[] searchArray = {2, 3, 4, 10, 40};
        int searchElement = 10;

        System.out.println("Original array1: ");
        for (int value : array1) {
            System.out.print(value + " ");
        }
        System.out.println();

        // Bubble Sort
        bubbleSort(array1);
        System.out.println("Bubble Sorted array1: ");
        for (int value : array1) {
            System.out.print(value + " ");
        }
        System.out.println();

        System.out.println("Original array2: ");
        for (int value : array2) {
            System.out.print(value + " ");
        }
        System.out.println();

        // Insertion Sort
        insertionSort(array2);
        System.out.println("Insertion Sorted array2: ");
        for (int value : array2) {
            System.out.print(value + " ");
        }
        System.out.println();

        System.out.println("Original array3: ");
        for (int value : array3) {
            System.out.print(value + " ");
        }
        System.out.println();

        // Quick Sort
        quickSort(array3, 0, array3.length - 1);
        System.out.println("Quick Sorted array3: ");
        for (int value : array3) {
            System.out.print(value + " ");
        }
        System.out.println();

        // Binary Search
        int binarySearchResult = binarySearch(searchArray, searchElement);
        if (binarySearchResult == -1)
            System.out.println("Element not present in binary search array");
        else
            System.out.println("Element found at index " + binarySearchResult + " in binary search array");

        // Linear Search
        int linearSearchResult = linearSearch(searchArray, searchElement);
        if (linearSearchResult == -1)
            System.out.println("Element not present in linear search array");
        else
            System.out.println("Element found at index " + linearSearchResult + " in linear search array");
    }


}
