import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

public class Control {
    public static void main(String[] args) {
        Hashtable<Integer, Integer> ht = new Hashtable<>();
        Integer n = Integer.valueOf(13);
        ht.put(n, Integer.valueOf(31));
        int m = ht.get(n).intValue();
        ht.put(14, 32);
        int k = ht.get(14);
        assert m == 31 && k == 32;

        Integer a = 1000, b = 1000;
        boolean sameObject = (a == b);
        boolean sameValue = a.equals(b);
        assert !sameObject && sameValue;

        List<String> out = new ArrayList<>();
        outerLoop:
        for (int i = 1; i <= 3; i++) {
            for (int j = 1; j <= 3; j++) {
                if (i == 2 && j == 2) {
                    continue outerLoop;
                }
                out.add(i + "," + j);
            }
        }
        assert out.equals(List.of("1,1", "1,2", "1,3", "2,1", "3,1", "3,2", "3,3"));
        System.out.println("ok");
    }
}
