# CFSelenium (DEPRECATED)
An opinionated Selenium framework for Coldfusion utilising the native Java-bindings

**NOTE: As of Feb 2021 this repo is now deprecated. I will no longer be maintaining this (to be fair, I already hadn't in a long time**

This framework aims to do the pretty much the same as teamcfadvance's CFSelenium: provide a native client library for the Selenium WebDriver that allows you to write tests, using CFML, which will drive a browser and allow you to interact with the page and elements.

I don't claim this is better; in fact it's approach is quite different - as this is full framework that abstracts and exposes Selenium in very specific ways to suit our company's needs.

That last bit is important. This framework was never made for general purpose use, and is laser focused on the need/style of the company I worked for. Therefore it may not be the least bit useful to a lot of people, as it abstracts only the things that were useful to us, and many of the design decisions throughout the framework may appear decidedly weird at closer inspection.

If nothing else I hope it serves as an insight into how one might create their own test framework built around something like Selenium. 

**IMPORTANT NOTE:**

Since making this framework I have switched employer and no longer use it professionally. As such it's likely not going to be updated anymore or at least not very frequently.

**ORIGINS:**

The project originally came about when my company decided to switch from our old test Javascript framework to using Selenium. 
teamcfadvance's CFSelenium was sadly not in a working state at that point and with no alternatives (and no time to waste), the only other option for me was to create my own framework from scratch, based on the native Java-bindings for Selenium.

**USAGE:**

I was encouraged to share this framework here on GitHub by my colleagues. As it stands the framework is provided "as is" and will not be extended according to feedback. It's public mostly for educational/curiosty reasons, so that anyone else who might want to see how Coldfusion and Selenium working together could be achieved and realized as a fully fledged framework. It's built completely around my way of working and it was never intended to be easy for others to utilize as a general purpose test tool.

**REQUIREMENTS/COMPATIBILITY:**

* **Lucee 5+** | Our company moved from ACF to Lucee a while ago, and since then I have started making use of Lucee-only code. Apologies for any ACF-users out there.
* Supports the use of Mark Mandel's **Javaloader**
* Tested to work with Selenium up to version **3.141.59**. Other versions may work but not guaranteed.

**SETUP:**

* Download the **Java**-bindings from Selenium's website. Unzip the file, find ALL the **jar**-files and put them in some directory somewhere. 

* Now you need a way for Lucee to access these files. There's multiple ways to do this, such as:
	* Via Application.cfc using **javasettings.loadPaths**
	* Via **JavaLoader** (https://github.com/markmandel/JavaLoader)
	* Edit Lucee's config to include / load the jar-files directly or dump them into the bundle folder (lucee/tomcat/lucee-server/bundles/). The is not recommended as conflicting classes/packages will cause Lucee to prioritize its own over Selenium's or you'll get OSGI bundle conflicts. But ultimately it's up to you.

* Find a way to load the CFC's from this repo. My approach previously was to "hardcode" the path (the code expected subfolder called **Components**) but now you can put it anywhere you want. Either set it up via mappings in the **Application.cfc**, add mappings via **Lucee admin** or whatever takes your fancy.

**CREATING A BROWSER INSTANCE:**

Basic usage is via the webdriver (**Browser.cfc**) which finds and returns HTML-elements (**Element.cfc**) for you. But first you need a browser-instance and to create that - for example Chrome running on Windows - you use WebdriverManager.cfc like this:

```coldfusion
<cfset Browser = WebdriverManagerInstance.createBrowser(
	browser="chrome",
	remote=true,
	remoteServerAddress="http://127.0.0.1:9515"
	platform="WINDOWS"
) />
```

By passing **remote** as **true** with **remoteServerAddress** referring to the address of the webdriver binary you get to see Chrome being opened and interacted with. This is useful if you want to eyeball your tests as they run. __Keep in mind__ that in order to do this you have to manually start the webdriver binary, which is usually only possible on localhost. So if you want to run tests against another server the **remoteServerAddress** has to refer to a machine running the **Selenium Standalone Server**. You'll have to Google how to set that up if you're interested.

Alternatively you can run in pure **local mode** where you pass the location of the webdriver binary and then under the hood Selenium will start the webdriver - as well as the browser in headless mode - and close them down again once the test is done. In this mode you obviously don't get to see the tests running. But you don't have to manage the lifecycle of the webdriver bin yourself of course:

```coldfusion
<cfset Browser = WebdriverManagerInstance.createBrowser(
	browser="chrome",
	pathToWebDriverBIN="C:\somepath\chromedriver.exe"
	platform="WINDOWS"
) />
```

You can also make use of a **driver service**. It functions similar to the local mode example above and allows Selenium to manage the lifecycle of the webdriver binary itself. How exactly it differs to the example above - or why it's better or worse - is unclear. In any case you first create the service and then the browser, telling it to use the service. Like this:

```coldfusion
<cfset DriverService = WebdriverManager.createService(
    browser="chrome",
    pathToWebDriverBIN="C:\somepath\chromedriver.exe"
) />

<cfset DriverService.start() />

<cfset Browser = WebdriverManager.createBrowser(
    browser="chrome",
    remote=true,
    remoteServerAddress=DriverService.getUrl(),
    platform="WINDOWS"
) />
```

Notice that you pass the webdriver binary location to the service this time. When you don't need the service any longer you call **DriverService.stop()**.
One advantage is that you could chose to run the driver-service on another machine, effectively having different machines for different platforms or even browsers. If that's something you find useful it might be better to have a look at the Selenium Server (GRID) instead (https://www.selenium.dev/documentation/en/grid/).

**ENABLING THE FRAMEWORK TO USE THE SELENIUM JAR-FILES**

I mentioned under setup that you need to make Selenium's jar-files available to the framework somehow. If you loaded them via javasettings in Application.cfc, by adding them to Lucee's load-folder, modified the loadpath etc. then you don't have to do anything more as they should be globally accessible to your entire Lucee installation.

There are two other ways to make the jars available to an application: via JavaLoader or more directly by passing a reference to the jar or the folder of the jar(s) in createObject(). Both options are supported by this framework.

Using JavaLoader - pass an instance of JavaLoader to **createBrowser** and/or **createService** via argument **javaLoaderReference**:

```coldfusion
<cfset Browser = WebdriverManagerInstance.createBrowser(
	browser="chrome",
	pathToWebDriverBIN="C:\somepath\chromedriver.exe"
	platform="WINDOWS",
	javaLoaderReference=variableContainingJavaloader
) />
```

Using folder path - pass the absolute path to a folder where Selenium's jars are located to **createBrowser** and/or **createService** via argument **seleniumJarsPath**:

```coldfusion
<cfset Browser = WebdriverManagerInstance.createBrowser(
	browser="chrome",
	pathToWebDriverBIN="C:\somepath\chromedriver.exe"
	platform="WINDOWS",
	seleniumJarsPath="C:\somepath\selenium_example\jars"
) />
```

**BASIC USAGE:**

Once you have the browser you can start getting element using the shorthand methods from **getElementBy()**, or for more advanced use by using **getElement()**:

```coldfusion
<cfset UsernameElement = Browser.getElementBy().name(name="Username", onlyElementsOfTag="input") />
```

__OR__

```coldfusion
<cfset UsernameElement = Browser.getElement(
	locator=Browser.createLocator(
		searchFor="input[name='Username']",
		locateUsing="cssSelector"
	)
) />
```

Then you can manipulate the element as you wish through the methods exposed by **Element.cfc** such as:

```coldfusion
<cfset UsernameElement.write(text=["Dave"]) />
<cfset UsernameElement.click() />
<cfset ClassAttribute = UsernameElement.getClassName() />
```

For CSS animations and AJAX you might need to wait until an element is visible or present:

```coldfusion
<cfset OutputElement = oBrowser.waitUntil(
	condition="visibilityOfElementLocated",
	elementOrLocator=oBrowser.createLocator(
		searchFor="OutputBox",
		locateUsing="id"
	)
) />
```

You manipulate the browser itself via the methods from **Browser.cfc** of course, such as:

```coldfusion
<cfset Browser.runJavascript(script="console.log('It works!')") />
<cfset Browser.navigateTo(url="www.interesting-website.com") />
```

Not everything is exposed via CF methods so sometimes you want to get the underlying **Java**-element. Like this example where we are maximizing the browser window by using the **RemoteWebdriver**-java class directly:

```coldfusion
<cfset oBrowser.getJavaWebDriver().manage().window().maximize() />
```

Special elements such as select-tags are manipulated via **SelectElement.cfc** via is injected into **Element.cfc**:

```coldfusion
<cfset Browser.getElementBy().id(id="actions").select().selectByVisibleText(text="Status update") />
```

You can check for elements without necessarily fetching them, both if they are present or how many of them there are, via **ElementExistenceChecker.cfc**:

```coldfusion
<cfif Browser.doElementsExist().byAttributeContains(attribute="title", value="Download", tagType="a") >
	// Do something
</cfif>
```

__OR__

```coldfusion
<cfset DownloadLinks = Browser.doElementsExist().howManyByAttributeEquals(
	attribute="title",
	value="Download",
	tagType="button"
) />
```

That should be enough to get you started. Make sure to check out the source code for other methods and how they are used. Everything should be documented with both methods- and argument-hints.
