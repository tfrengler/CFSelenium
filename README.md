# CFSelenium
A Selenium framework for Coldfusion utilising the native Java-bindings

This framework aims to do the same as teamcfadvance's CFSelenium: provide a native client library for the Selenium WebDriver that allows you to write tests, using CFML, which will drive a browser and verify results.

ORIGINS:

The project originally came about when my company decided to switch from our old test Javascript framework to using Selenium. 
teamcfadvance's CFSelenium was sadly not in a working state at that point and with no alternatives (and no time to waste), the only other
option for me was to create my own framework from scratch, based on the native Java-bindings for Selenium.

I was encouraged to share this framework here on GitHub by my colleagues. As it stands the framework is provided "as is" and will not be modified or fixed according to feedback. Since it was primarily created to fit our way of working and within our organization it may very well not be to everyone's liking.

WHAT TO EXPECT:

Don't come expecting a fully fledged framework that will suit all your needs and covers all of Selenium's features. Don't get me wrong: it works and does what it does well, but the goal is just as much to show that it's possible to create a Selenium framework for Coldfusion and offer an example of how that can be achieved. So feel free to download it, modify, change and extend it as much as possible or just use it as research to figure out how to pull it off yourself.

In general most of the Java interactions are abstracted away and you'll be doing all your calls to Coldfusion objects and code. Although most Java objects are wrapped I have made public methods that can get you the original Java object so that you'll still be able to access all the original Selenium functions directly. I have only wrapped the most commonly used (for my company anyway) Selenium methods and functions, which are then exposed via CF methods.

USAGE:

The WebdriverManager.cfc is the interface for creating the webdriver (which I call a browser) and optionally a service (which is not abstracted, it's a Java object). Creating a webdriver for Chrome for example would look like this:

<cfset Browser = createObject('component', 'Components.WebDriverManager').createBrowser(
	Browser='Chrome'
) />

This would create a local webdriver that runs on your machine, meaning you need to have the webdriver binaries installed on your local and you need to point the application at them.

Alternatively you could do this:

<cfset Browser = createObject('component', 'Components.WebDriverManager').createBrowser(
	Browser='Chrome',
	Remote=true,
	RemoteServerAddress='http://localhost:9515',
) />

Which means you tell the webdriver to execute in remote mode but you point it at your local. In this way you can put your webdriver binaries whereever you want but you need to manually start and close them. For true remote mode you'd point RemoteServerAddress at the actual machine running the standalone Selenium server.

The actual magic of grabbing and interacting with a page happens inside Browser.cfc where you can utilize the methods getElementBy(), getElement() and getElements(). The latter two offer the most control over how to target elements, whereas getElementBy() is a shorthand interface for a single grabbing element, utilizing methods such as getElementBy().class(), getElementBy().id() and getElementBy().textContent().

NOTES/TROUBLESHOOTING:

There are a few hardcoded things in the code that I still have to remove or redo for this public version such as:

WebdriverManager.cfc has references to an application mapping called "DriverBins", which is the folder where you keep your webdriver binaries.

A lot of the object creations rely on our application mappings (all of the CFCs from this project live in a subfolder called Components for example). They need to be removed.
