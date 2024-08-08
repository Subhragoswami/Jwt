package com.jwt;

public class Oop {
    public static void main(String[] args) {
        Vehicle myCar = new Car("Toyota", "Camry", 2021, "Petrol");
        Vehicle myBike = new Motorcycle("Honda", "CBR", 2018);

        System.out.println("Car Make: " + myCar.getMake());
        System.out.println("Motorcycle Model: " + myBike.getModel());

        myCar.start();
        myBike.start();

        ((Car) myCar).start(true);


        System.out.println("Car Fuel Type: " + ((Car) myCar).getFuelType());
    }

}

abstract class Vehicle {
    private String make;
    private String model;
    private int year;

    public Vehicle(String make, String model, int year) {
        this.make = make;
        this.model = model;
        this.year = year;
    }


    public abstract void start();

    public String getMake() {
        return make;
    }

    public void setMake(String make) {
        this.make = make;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }
}

class Car extends Vehicle {
    private String fuelType;

    public Car(String make, String model, int year, String fuelType) {
        super(make, model, year);
        this.fuelType = fuelType;
    }

    @Override
    public void start() {
        System.out.println(getMake() + " " + getModel() + " (" + getYear() + ") starts with a key.");
    }

    public void start(boolean isRemote) {
        if (isRemote) {
            System.out.println(getMake() + " " + getModel() + " (" + getYear() + ") starts remotely.");
        } else {
            start();
        }
    }

    public String getFuelType() {
        return fuelType;
    }

    public void setFuelType(String fuelType) {
        this.fuelType = fuelType;
    }
}

class Motorcycle extends Vehicle {

    public Motorcycle(String make, String model, int year) {
        super(make, model, year);
    }

    @Override
    public void start() {
        System.out.println(getMake() + " " + getModel() + " (" + getYear() + ") starts with a kick.");
    }
}

