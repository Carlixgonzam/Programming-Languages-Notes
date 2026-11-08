import java.util.List;

public class Generics {
    record MyPair<A, B>(A x, B y) {}

    static <T> T id(T x) { return x; }

    static <A> A head(List<A> lst) { return lst.get(0); }

    public static void main(String[] args) {
        var p = new MyPair<>(1, "Java");
        var q = id(1);
        var result = head(List.of(1, 2, 3));
        var pairs = List.of(new MyPair<>(1, "a"), new MyPair<>(2, "b"));
        Integer x = p.x();
        String y = p.y();
        assert x == 1 && y.equals("Java");
        assert q == 1 && result == 1 && pairs.size() == 2;
        System.out.println("ok");
    }
}
