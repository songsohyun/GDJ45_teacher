package ex10_override;

public class Regular extends Employee {

	private int salary;

	public Regular(String name, int salary) {
		super(name);
		this.salary = salary;
	}
	
	@Override
	public int getPay() {
		return salary;
	}
	
}
