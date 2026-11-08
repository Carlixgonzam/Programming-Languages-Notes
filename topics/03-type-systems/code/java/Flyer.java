public class Flyer {
    // <<nominal>>
    interface Flying { String fly(); }

    // Duck says that it is a Flying: nominal subtyping.
    static class Duck implements Flying {
        public String fly() { return "flap flap"; }
    }
    // <<nominal.end>>

    // <<variance>>
    static class Animal {}
    static class Dog extends Animal {}

    static Animal pick(java.util.List<? extends Animal> animals) { return animals.get(0); }
    // <<variance.end>>

    public static void main(String[] args) {
        Flying f = new Duck();
        assert f.fly().equals("flap flap");
        java.util.List<Dog> dogs = java.util.List.of(new Dog());
        assert pick(dogs) instanceof Dog;
        System.out.println("ok");
    }
}
