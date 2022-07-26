package ex01.main;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/*
	 Job
	 
	 1. Scheduler가 수행할 작업이다.
	 2. Job 인터페이스를 구현하면 된다.
*/

public class HelloJob implements Job {

	@Override
	public void execute(JobExecutionContext arg0) throws JobExecutionException {
		
		System.out.println("Hello World");
		
	}

}
