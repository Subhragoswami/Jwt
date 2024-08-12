package com.jwt;

import lombok.extern.slf4j.Slf4j;


// 1. Single Responsibility Principle (SRP)
class Book {
    private String title;
    private String author;

    public Book(String title, String author) {
        this.title = title;
        this.author = author;
    }

    public String getTitle() {
        return title;
    }

    public String getAuthor() {
        return author;
    }
}

class LibraryCatalog {
    public void addBook(Book book) {
        System.out.println("Book added: " + book.getTitle());
    }

    public void removeBook(Book book) {
        System.out.println("Book removed: " + book.getTitle());
    }
}

// 2. Open/Closed Principle (OCP)
abstract class Notification {
    public abstract void sendNotification(String message);
}

class EmailNotification extends Notification {
    @Override
    public void sendNotification(String message) {
        System.out.println("Email sent: " + message);
    }
}

class SMSNotification extends Notification {
    @Override
    public void sendNotification(String message) {
        System.out.println("SMS sent: " + message);
    }
}

// 3. Liskov Substitution Principle (LSP)
class Member {
    public void borrowBook(Book book) {
        System.out.println("Borrowing book: " + book.getTitle());
    }
}

class PremiumMember extends Member {
    @Override
    public void borrowBook(Book book) {
        super.borrowBook(book);
        System.out.println("Premium member gets extra benefits.");
    }
}

// 4. Interface Segregation Principle (ISP)
interface Borrowable {
    void borrowItem();
}

interface Returnable {
    void returnItem();
}

class BorrowableBook implements Borrowable {
    @Override
    public void borrowItem() {
        System.out.println("Borrowing book...");
    }
}

class ReturnableBook implements Returnable {
    @Override
    public void returnItem() {
        System.out.println("Returning book...");
    }
}

// 5. Dependency Inversion Principle (DIP)
interface Database {
    void connect();
    void disconnect();
}

class MySQLDatabase implements Database {
    @Override
    public void connect() {
        System.out.println("Connected to MySQL Database.");
    }

    @Override
    public void disconnect() {
        System.out.println("Disconnected from MySQL Database.");
    }
}

class LibraryManagementSystem {
    private final Database database;

    public LibraryManagementSystem(Database database) {
        this.database = database;
    }

    public void manageLibrary() {
        database.connect();
        System.out.println("Managing library operations...");
        database.disconnect();
    }
}

@Slf4j
public class solidDesignPrinciples {
    public static void main(String[] args) {
        // SRP
        Book book1 = new Book("1984", "George Orwell");
        LibraryCatalog catalog = new LibraryCatalog();
        catalog.addBook(book1);

        // OCP
        Notification emailNotification = new EmailNotification();
        emailNotification.sendNotification("Your book is due tomorrow.");

        Notification smsNotification = new SMSNotification();
        smsNotification.sendNotification("Your book is due today.");

        // LSP
        Member regularMember = new Member();
        regularMember.borrowBook(book1);

        PremiumMember premiumMember = new PremiumMember();
        premiumMember.borrowBook(book1);

        // ISP
        Borrowable borrowableBook = new BorrowableBook();
        borrowableBook.borrowItem();

        Returnable returnableBook = new ReturnableBook();
        returnableBook.returnItem();

        // DIP
        Database mysqlDatabase = new MySQLDatabase();
        LibraryManagementSystem librarySystem = new LibraryManagementSystem(mysqlDatabase);
        librarySystem.manageLibrary();
    }
}