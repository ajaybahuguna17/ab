package com.bjs.dev;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.edge.EdgeDriver;

public class Login {
	ChromeDriver driver;
	By unXpath = By.xpath("//input[@name='username']");
	By pwXpath = By.xpath("//input[@name='password']");
	By subXpath = By.xpath("//button[@type='submit']");
	public Login(ChromeDriver driver) {
		this.driver=driver;
	}
	public void typeusername()
	{
		driver.findElement(unXpath).sendKeys("Admin");
	}
public void typepassword()
{
	driver.findElement(pwXpath).sendKeys("admin123");
}
public void typesubmit()
{
	driver.findElement(subXpath).click();
}

}
