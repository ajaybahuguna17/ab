package com.bjs.dev;

import org.openqa.selenium.By;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.edge.EdgeDriver;

public class Homepage {
	ChromeDriver driver;
	By oinc = By.xpath("//a[text()='OrangeHRM, Inc']");
	public Homepage(ChromeDriver driver2) {
		driver=driver2;
	}
	public void clickoinc()
	{
		driver.findElement(oinc).click();
	}

}
