public class Flyer {
    interface Flying { String fly(); }

    static class Duck implements Flying {
        public String fly() { return "flap flap"; }
    }

    static class Animal {}
    static class Dog extends Animal {}

    static Animal pick(java.util.List<? extends Animal> animals) { return animals.get(0); }

    public static void main(String[] args) {
        Flying f = new Duck();
        assert f.fly().equals("flap flap");
        java.util.List<Dog> dogs = java.util.List.of(new Dog());
        assert pick(dogs) instanceof Dog;
        System.out.println("ok");
    }
}
