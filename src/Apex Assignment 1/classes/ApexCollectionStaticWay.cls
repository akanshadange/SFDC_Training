/*
Purpose			: Assignment 1 > Static Way to fill List,Set and Map.
Created Date	: 25-11-24
Created By		: Akansha Dange
*/

public class ApexCollectionStaticWay { 
    public static void departmentEmployees() {
        Map<String, List<String>> departmentWithEmployees = new Map<String, List<String>>();
        departmentWithEmployees.put('HR', new List<String>{'Sai','Neha','Meha'});
        departmentWithEmployees.put('Engineering', new List<String>{'David', 'Henna'});
        departmentWithEmployees.put('Sales', new List<String>{'Hannah', 'Will', 'Jack'});
        for (String department : departmentWithEmployees.keySet()) {
            System.debug('Department: ' + department + ', Employees: ' + departmentWithEmployees.get(department)); 
        }
    }
    
    public static void studentsCalculation() {
        Set<String> studentA = new Set<String>{'Alice', 'Bob', 'Charlie', 'David'};
        Set<String> studentB = new Set<String>{'Charlie', 'David', 'Hena', 'Will'};
                
        Set<String> unionSet = studentA.clone();
        unionSet.addAll(studentB);   
        System.debug(unionSet);
        
        Set<String> intersectionSet = new set<String>(studentA);
        intersectionSet.retainAll(studentB);
        System.debug(intersectionSet);   
        
        Set<String> differenceA = new Set<String>(studentA);
        differenceA.removeAll(studentB);
        System.debug(differenceA);
        
        Set<String> differenceB = new Set<String>(studentB);
        differenceB.removeAll(studentA);
        System.debug(differenceB);
    }  
    
    public static void sortingNumbers() {
        List<Integer> numbers = new List<Integer>{5,3,7,1,4,9,6,2,8};
        numbers.sort();
        System.debug(numbers);
    }
}