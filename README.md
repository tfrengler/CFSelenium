# CFSelenium
A Selenium framework for Coldfusion utilising the native Java-bindings

This framework aims to do the pretty much the same as teamcfadvance's CFSelenium: provide a native client library for the Selenium WebDriver that allows you to write tests, using CFML, which will drive a browser and allow you to interact with the page and elements.

I don't claim this is better; in fact it's approach is quite different so I recommend you check out both.

**LICENSE**

MIT License

Copyright (c) 2018 Thomas Grud Frengler

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

**ORIGINS:**

The project originally came about when my company decided to switch from our old test Javascript framework to using Selenium. 
teamcfadvance's CFSelenium was sadly not in a working state at that point and with no alternatives (and no time to waste), the only other option for me was to create my own framework from scratch, based on the native Java-bindings for Selenium.

I was encouraged to share this framework here on GitHub by my colleagues. As it stands the framework is provided "as is" and will most likely not be extended according to feedback, but I will try to fix outright errors. Since it was primarily created to fit our way of working within our organization it may very well not be to everyone's liking. Take it or leave it basically.

**REQUIREMENTS**

As far as I am aware it will work with Lucee all the way down to 4.5.
For Adobe Coldfusion you'll need atleast 10+ although I am not 100% sure.
I developed this against Adobe Coldfusion 2016 and I have not paid special attention to what newer features I've used.

As far as folder structure goes there is but one requirement: 

**1:** All the CFCs from here are in a subfolder directly under the Application-root called **Components**.

**SETTING UP - SELENIUM'S JAR FILES**

You need Selenium's Java bindings (obviously) which you can get here: http://selenium-release.storage.googleapis.com/index.html
Note that you need the **selenium-server** files! Next step is how to load in the jar files in Coldfusion. There are two supported ways to go about this:

- Putting them inside the Coldfusion root folder\WEB-INF\libs. From here they'll be automagically loaded in when CF starts up.
- Use Mark Mandel's excellent Javaloader to load the jar files.

You can't use the class path in the admin interface to load the jar files. There's some overlap between classes and methods used by CF and Selenium, and since CF's take precedence, Selenium won't work.

I built in support for Javaloader and that's what I use myself. All you need to do is to pass an extra argument to **createBrowser()** in **WebdriverManager.cfc** (see next section) which points to the folder where your Selenium jar files are. Note that all the jar files from the .zip should be in ONE folder (no subfolders)!.

**SETTING UP - CREATING A WEBDRIVER**

The **WebdriverManager.cfc** is the interface for creating the webdriver (which I call a Browser) and optionally a service (which is not abstracted, it's the original Selenium Java object). The simplest example for creating a webdriver for Chrome would look like this:
```
<cfset Browser = createObject('component', 'Components.WebDriverManager').createBrowser(Browser='Chrome') />
```
This would create a local webdriver that runs on your machine, meaning you need to have the webdriver binaries somewhere (up to you) on your local machine. If you are ONLY running your tests remotely (for which you need a server running the Selenium Standalone Server) you can omit putting the webdriver binaries on your local machine.

Alternatively for running on local you could also do this:
```
<cfset Browser = createObject('component', 'Components.WebDriverManager').createBrowser(
	browser='Chrome',
	remote=true,
	remoteServerAddress='http://localhost:9515',
) />
```
Which means you tell the webdriver to execute in remote mode but you point it at your local. In this way you can put your webdriver binaries whereever you want but you need to manually start and close the binaries. For true remote mode you'd point **RemoteServerAddress** at the actual machine running the standalone Selenium server.

If you're intent on using Javaloader to load the Selenium jars you have to instantiate javaloader somewhere and then pass in a reference to createBrowser():
```
<cfset Browser = createObject('component', 'Components.WebDriverManager').createBrowser(
	javaLoaderReference = javaloaderobject
) />
```
The WebdriverManager.cfc is static and is meant to work as a singleton. It doesn't allow you to modify its internal variables and it doesn't rely on them changing at all. So in your own environment you could put it in a (semi)persistent scope and use it to create webdrivers and services.

**USAGE**

I recommend taking a look through the code to see what methods you've got available, and the arguments they accept. Broadly speaking the **Browser.cfc** is for interacting with the browser and **Element.cfc** is for interacting with a DOM element.

Below are some explanations along with examples.

**INTERACTING WITH THE BROWSER**

Inside **Browser.cfc** are the methods for interacting with the browser:

- getElementBy()
- getElement()
- getElements()
- navigateTo()
- quit()
- runJavascript()
- takeScreenshot()

**navigateTo()** is one of the most obvious ones you'll use a lot, as well as the getElement-methods. **quit()** closes the browser and ends the session.

**GRABBING ELEMENTS**

As mentioned above the magic of grabbing and interacting with elements happens inside **Browser.cfc**. Here you have two choices:

**1:** Use **getElement()** or which allows you the most specific control over how to target elements or...

**2:** Use **getElementBy()** which is an interface for **ElementLocator.cfc** that has easy to use methods for grabbing elements by the most common means, such as ID, class, name, value etc.

The syntax is:
```
<cfset AnElement = Browser.getElement(
	locator=MyLocator,
	locateHiddenElements=false,
	multiple=false
)/ >
```
Broken down the arguments are:

- **locator (instanceOf Locator.cfc):** An instance of Locator.cfc which encapsulates the mechanism you want to use to fetch an element (more on that in a moment).
- **locateHiddenElements (boolean):** Use this to one-time override the default element fetch behaviour regarding returning only elements that are considered visible.
- **multiple (boolean):** Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found.

The mechanism needed to tell getElement() what to fetch and how is the Locator.cfc I just mentioned above. Browser contains a method for spawning locators, which works like this:

```
<cfset MyLocator = Browser.createLocator(
	searchFor="input[name='CreditcardNumber']",
	locateUsing="cssSelector"
)/ >
```
The arguments for this are:

- **searchFor (string):** The string you want to search for.
- **locateUsing (string):** The locator mechanism you want to use to find the element(s). Valid locators are: id,cssSelector,xpath,name,className,linkText,partialLinkText,tagName,javascript.
- **javascriptArguments (array):** Arguments for the javascript locator. Script arguments must be a number, a boolean, a string, RemoteWebElement, or an array of any of those combinations.

So you'd use these two together like such:
```
<cfset MyLocator = Browser.createLocator(
	searchFor="input[name='CreditcardNumber']",
	locateUsing="cssSelector"
)/ >

<cfset AnElement = Browser.getElement(
	locator=MyLocator,
	locateHiddenElements=false,
	multiple=false
)/ >

OR INLINE:

<cfset AnElement = Browser.getElement()
	locator=Browser.createLocator(searchFor="input[name='CreditcardNumber']", locateUsing="cssSelector"),
	locateHiddenElements=false,
	multiple=false
/ >
```

There's another way to grab elements which is called **getElementBy()** and may for the most part what you'd use, unless you desire advanced control over what you're searching for. It creates the locators that it uses itself, meaning less code for you to achieve the same effect! It contains methods such as:

- title()
- id()
- class()
- name()
- textEquals()
- textContains()
- inputType()
- value()
- attributeStartsWith()
- attributeEndsWith()
- attributeContains()

The arguments for these (except the last three) are pretty much identical:
```
<cfset AnElement = Browser.getElementBy().name(
	name="Remove",
	onlyElementsOfTag="button",
	multiple=false
) />
```
Broken down the arguments are:

- **name (string):**  The name of the element you want to search for.
- **onlyElementsOfTag (string):** Specify a tag name to limit the search to only this type of HTML tag. So for example pass as 'div' to only search for divs with a certain name, rather than any element.
- **multiple (boolean):** Whether you want to fetch a single element or multiple. Keep in mind that this will return an array, even an empty one, if no elements are found.

The **attributeXXX**-methods all have these parameters in common:

- **attribute (string):** The name of the attribute you want to search for.
- **value (string):** The value of the attribute you want to search for.

An example use would be this:
```
<cfset SomeElements = Browser.getElementBy().attributeStartsWith(
	attribute="value",
	value="Password",
	onlyElementsOfTag="input",
	multiple=true
) />
```
Aside from **onlyElementsOfTag** and **multiple** which they all have in common, there's also **getLocator**. 
So calling **getElementBy().name()** or **.getElementBy().attributeStartsWith()** as we did above but adding **getLocator=true** we'd instead get an instance of Locator.cfc with the mechanism that would be used to fetch that element.
It can be useful to retrieve the locator, rather than the element, as there are Selenium methods that use element locators for certain things, such as conditions.

**INTERACTING WITH ELEMENTS**

Once you've gotten an element you can get information about it or interact with it. This is done on the element itself of course, the methods for doing so coming from **Element.cfc**:

- getId()
- getClassName()
- getTagName()
- getName()
- getTextContent()
- getHTMLContent()
- getAttribute()
- isDisplayed()
- isEnabled()
- selectIfNotSelected()
- deselectIfSelected()
- write()
- click()
- clearText()
- getParentElement()
- getPreviousSiblingElement()
- getNextSiblingElement()

**click()** and **write()** are probably the interaction methods you'll use most. click() is selfexplanatory. write() accepts an argument called **text** which may surprise you to learn is an array and not a string. This is how the underlying Java method works as well so I chose to keep it that way. Furthermore, while the Java method by default ADDS to the existing text in an element, my method first clears it and then writes in it. There's a boolean argument to write() called **addToExistingText** to allow it to append the text instead.

There's also an extension called **SelectElement.cfc** that you can grab via the select()-method. This is an interface for interacting with select-elements that require some additional logic:

- getNumberOfOptions()
- getAllOptions()
- getAllSelectedOptions()
- getFirstSelectedOption()
- selectByVisibleText()
- selectByIndex()
- selectByValue()
- deselectAll()
- deselectByValue()
- deselectByIndex()
- deselectByVisibleText()

**EXAMPLES AND NOTES**

Note that the methods that target single elements will be throwing errors if it can't find any elements matching your criteria. If you want to check for element existence use the boolean **multiple**-argument with the getElementBy()-methods. Or use getElements() instead. They both return an array, empty if no elements were found.

Not every single thing is exposed via CFML but you can grab the Java-object and use the native methods directly. You can grab the Java webdriver in Browser.cfc using getJavaWebDriver() and you can get the Java WebElement from Element.cfc using getJavaElement(). Here's an example of using the Java object to maximize the browser window:
```
<cfset Browser.getJavaWebDriver().manage().window().maximize() />
```
Here's an example from one of my scripts at work so you can see the flow. It uses a variety of methods, including Selenium's native Java object, for dealing with frames for example:
```
<cfset oBrowser.navigateTo(URL=vacancyPortalPage) />

<cfset oBrowser.getElementBy().id( id="LeftNavVacaturesAnchor" ).click() />
<cfset oBrowser.getElement(
	searchFor="button[title^='Add']",
	locateUsing=["cssSelector"]
	).click() 
/>

<cfset oBrowser.getElementBy().title(Title="Next").click() />
<cfset oBrowser.getElementBy().id(id="Naam").write(Text=["Vacancy ", stTestData.testIDName]) />
<cfset oBrowser.getElementBy().name(Name="Save").click() />

<cfset oBrowser.runJavascript(Script="collapseAll()") />
<cfset vacancyID = oBrowser.getElementBy().id(id="VacatureID").getValue() />

<cfset oBrowser.getElementBy().name(name="Delete").click() />
<cfset oBrowser.getJavaWebDriver().switchTo().alert().accept() />

<cfset aBrowserWindowHandles = oBrowser.getJavaWebdriver().getWindowHandles().toArray() /> 
<cfset oBrowser.getJavaWebdriver().switchTo().window(aBrowserWindowHandles[2]) />
<cfset externalID = oBrowser.getElementBy().id(id="ExternalID").getValue() />

<cfset oBrowser.close() />
<cfset oBrowser.getJavaWebdriver().switchTo().window(aBrowserWindowHandles[1]) />

<cfset oBrowser.getElementBy().id(id="Vacancytype").select().selectByVisibleText(Text=testVacancyType) />
```
**WHAT TO EXPECT (AND NOT EXPECT):**

Don't expect a framework that will suit all your needs and covers all of Selenium's features. It's developed and maintained by just me, and its development is driven by my company's needs. You can always modify, change and extend it as much as possible or just use it as research to figure out how to pull it off yourself.

The biggest difference between this and teamcfadvance's CFSelenium is that theirs is really a barebones factory for initializing Selenium. It's awesome if you crave completely control and offers the most flexibility. It comes with the overhead of you having to build a framework around it yourself if you want more than interact with the raw Java-methods. My framework on the other hand locks you into using it my way, so if you don't want that this might not be for you.

In general most of the Java interactions are abstracted away and you'll be doing all your calls to Coldfusion objects and code. As mentioned already I have made public methods that can get you the original Java object so that you'll still be able to access all the original Selenium functions directly. I have wrapped the most commonly used Selenium methods and added my own original methods for things that I find handy.

The framework as I present it here it also completely stand-alone. This means I built no support for plugging in reporters, testrunners, or any kind of known (or unknown) test harnesses or frameworks of any kind. That's completely out of scope of what I wanted; you'd have to build that kind of hook yourself.

There's a copious amount of type checking and error handling because that's one of my personal bugbears. Also the framework is liberal about using throws and custom exceptions when it hits conditions that are considered bad. My aim was to abstract away some of the frankly quite esoteric errors that Selenium occasionally throws and give you clear, concise information about what went wrong so you can easily find and fix it.

**NOTES/TROUBLESHOOTING:**

No outstanding issues that I know of.

**CONTACT AND FEEDBACK:**

I'm always open for comments or feedback, as long as it's constructive. You can reach me at tfrengler@talentsoft.com
