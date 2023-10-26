package com.bjs.tes;

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.edge.EdgeDriver;
import org.testng.annotations.Test;

import com.bjs.dev.Homepage;
import com.bjs.dev.Login;


public class OrangeHrmTest {
     @Test   
	public void method() throws InterruptedException {
		ChromeDriver driver = new ChromeDriver();
		driver.manage().window().maximize();
		driver.get("https://opensource-demo.orangehrmlive.com/web/index.php/auth/login");
		driver.manage().timeouts().implicitlyWait(5, TimeUnit.SECONDS);
Login lg = new Login(driver);
lg.typeusername();
lg.typepassword();
lg.typesubmit();
Thread.sleep(5000);
Homepage hp = new Homepage(driver);
	hp.clickoinc();
	
						}

}
