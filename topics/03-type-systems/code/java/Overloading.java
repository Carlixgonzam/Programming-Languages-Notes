public class Overloading {
    static int add(int a, int b) { return a + b; }
    static String add(String a, String b) { return a + b; }

    interface Speak { String speak(); }

    record Dog() implements Speak { public String speak() { return "Woof"; } }
    record Cat() implements Speak { public String speak() { return "Meow"; } }

    static <T extends Speak> String greet(T x) {
        return "Hello, " + x.speak();
    }

    public static void main(String[] args) {
        assert add(1, 2) == 3;
        assert add("a", "b").equals("ab");
        assert greet(new Dog()).equals("Hello, Woof");
        assert greet(new Cat()).equals("Hello, Meow");
        System.out.println("ok");
    }
}
