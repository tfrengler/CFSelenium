# CFSelenium
A Selenium framework for Coldfusion utilising the native Java-bindings

This framework aims to do the same as teamcfadvance's CFSelenium: provide a native client library for the Selenium WebDriver that allows you to write tests, using CFML, which will drive a browser and verify results.

<b>ORIGINS:</b>

The project originally came about when my company decided to switch from our old test Javascript framework to using Selenium. 
teamcfadvance's CFSelenium was sadly not in a working state at that point and with no alternatives (and no time to waste), the only other
option for me was to create my own framework from scratch, based on the native Java-bindings for Selenium.

I was encouraged to share this framework here on GitHub by my colleagues. As it stands the framework is provided "as is" and will not be extended according to feedback, but I will try to fix outright errors. Since it was primarily created to fit our way of working within our organization it may very well not be to everyone's liking. Take it or leave it basically.

<b>WHAT TO EXPECT (AND NOT EXPECT):</b>

Don't come expecting a fully fledged framework that will suit all your needs and covers all of Selenium's features. Don't get me wrong: it works and does what it does well, but the goal is just as much to show that it's possible to create a Selenium framework for Coldfusion and offer a working example of how that can be achieved. So feel free to download it, modify, change and extend it as much as possible or just use it as research to figure out how to pull it off yourself.

In general most of the Java interactions are abstracted away and you'll be doing all your calls to Coldfusion objects and code. Although most Java objects are wrapped I have made public methods that can get you the original Java object so that you'll still be able to access all the original Selenium functions directly. I have only wrapped the most commonly used (to me anyway) Selenium methods and functions, which are then exposed via CF methods.

The framework as I present it here it also completely stand-alone. This means I built no support in for reporters, testrunners, or any kind of known (or unknown) test harnesses or frameworks of any kind. You'd have to build that kind of hook yourself.

There's a copious amount of type checking and error handling because that's one of my personal bugbears. Also the framework is liberal about using <cfthrow> when it hits conditions that are considered bad. My aim was to abstract away some of the frankly quite esoteric errors that Selenium occasionally throws and give you clear, concise information about what went wrong so you can easily find and fix it.

<b>USAGE:</b>

<b>Setting up</b>

The WebdriverManager.cfc is the interface for creating the webdriver (which I call a Browser) and optionally a service (which is not abstracted, it's the original Selenium Java object). Creating a webdriver for Chrome for example would look like this:
```
<cfset Browser = createObject('component', 'Components.WebDriverManager').createBrowser(Browser='Chrome') />
```
This would create a local webdriver that runs on your machine, meaning you need to have the webdriver binaries installed on your local and you need to point the application at them. 

Yes, there's a mapping in front of the CFC name. I struggled with trying to maintain two separate versions of the code (for work and for here) so all the code is straight from my work versions, which means the CFCs are expected to live in specific places, in this case a subfolder somewhere called "Components".

Alternatively you could do this:
```
<cfset Browser = createObject('component', 'Components.WebDriverManager').createBrowser(
	Browser='Chrome',
	Remote=true,
	RemoteServerAddress='http://localhost:9515',
) />
```
Which means you tell the webdriver to execute in remote mode but you point it at your local. In this way you can put your webdriver binaries whereever you want but you need to manually start and close them. For true remote mode you'd point RemoteServerAddress at the actual machine running the standalone Selenium server.

The WebdriverManager.cfc is static and is meant to work as a singleton. It doesn't allow you to modify its internal variables and it doesn't rely on them changing at all. So in your own environment you could put it in a (semi)persistent scope and use it to create webdrivers and services.

<b>Navigating pages and interacting with elements</b>

The actual magic of grabbing and interacting with a page happens inside Browser.cfc where you can utilize the methods:
```
getElementBy()
getElement()
getElements()
```
The latter two offer the most manual control over how to target elements, whereas getElementBy() is a shorthand interface I made for getting a single element (but it can also grab multiple elements via an argument), utilizing methods such as:
```
getElementBy().class()
getElementBy().id()
getElementBy().textContent()
```
Example of using the webdriver to navigate:
```
<cfset Browser.navigateTo(URL="www.mytestpage.com") />
```
Example of grabbing an textarea or input-text element and writing in it (using getElement):
```
<cfset Browser.getElement(SearchFor="username",LocateUsing=["name"]).write( Text=["test"] ) />
```
or clicking on the element (using getElementBy instead)
```
<cfset Browser.getElementBy().name(name="username").click() />
```
Note that the methods that target single elements will be throwing errors if it can't find any elements matching your criteria. If you want to check for element existence use the boolean "Multiple"-argument with the getElementBy()-methods - or use getElements() instead - both of which return an array.

As mentioned earlier not every single thing is exposed via CFML but you can grab the Java-object and use the native methods directly. Here's an example of maximizing the browser window:
```
<cfset Browser.getJavaWebDriver().manage().window().maximize() />
```

<b>NOTES/TROUBLESHOOTING:</b>

No outstanding issues that I know of. I removed our hardcoded application mappings that were used for component creation and for pointing to a directory where we store our webdriver binaries.

<b>CONTACT AND FEEDBACK:</b>

I'm always open for comments or feedback, as long as it's constructive. You can reach me at tfrengler@talentsoft.com
