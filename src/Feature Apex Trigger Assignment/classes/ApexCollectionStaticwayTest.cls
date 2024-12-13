@isTest
public class ApexCollectionStaticwayTest {
    @isTest
    public static void testdepartmentEmployees(){
        Test.startTest();
        Map<String, List<String>> result = ApexCollectionStaticWay.departmentEmployees();
        Test.stopTest();
        Assert.areEqual(result.size(),3);
        Assert.isTrue(result.containsKey('HR'));
        Assert.areEqual(new List<String>{'Sai', 'Neha', 'Meha'},result.get('HR'));
        Assert.isTrue(result.containsKey('Engineering'));
        Assert.areEqual(new List<String>{'David', 'Henna'},result.get('Engineering'));
        Assert.isTrue(result.containsKey('Sales'));
        Assert.areEqual( result.get('Sales'),new List<String>{'Hannah', 'Will', 'Jack'});
   }

    @isTest
    static void testStudentsCalculation() {
        Set<String> expectedUnion = new Set<String>{'Alice', 'Bob', 'Charlie', 'David', 'Hena', 'Will'};
        Set<String> expectedIntersection = new Set<String>{'Charlie', 'David'};
        Set<String> expectedDifferenceA = new Set<String>{'Alice', 'Bob'};
        Set<String> expectedDifferenceB = new Set<String>{'Hena', 'Will'};
        Test.startTest();
        Map<String, Set<String>> result = ApexCollectionStaticWay.studentsCalculation();
        Test.stopTest();
        Assert.areEqual(result.get('Union'),expectedUnion);
        Assert.areEqual(result.get('Intersection'),expectedIntersection);
        Assert.areEqual(result.get('DifferenceA'),expectedDifferenceA);
        Assert.areEqual(result.get('DifferenceB'),expectedDifferenceB);

}

    @isTest
    public static void testSortingNumbers() {
        //List<Integer> numbers = new List<Integer>{5, 3, 7, 1, 4, 9, 6, 2, 8};
        List<Integer> sortedList = new List<Integer>{1, 2, 3, 4, 5, 6, 7, 8, 9};
        Test.startTest();
        ApexCollectionStaticWay.sortingNumbers(); 
        Test.stopTest();
        Assert.areEqual(1,sortedList[0]);
        Assert.areEqual(2,sortedList[1]);
        Assert.areEqual(7,sortedList[6]);
   }
}