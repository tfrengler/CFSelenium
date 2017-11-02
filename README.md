# CFSelenium
A Selenium framework for Coldfusion utilising the native Java-bindings

This framework aims to do the same as teamcfadvance's CFSelenium: provide a native client library for the Selenium WebDriver that allows you to write tests, using CFML, which will drive a browser and verify results.

**ORIGINS:**

The project originally came about when my company decided to switch from our old test Javascript framework to using Selenium. 
teamcfadvance's CFSelenium was sadly not in a working state at that point and with no alternatives (and no time to waste), the only other
option for me was to create my own framework from scratch, based on the native Java-bindings for Selenium.

I was encouraged to share this framework here on GitHub by my colleagues. As it stands the framework is provided "as is" and will not be extended according to feedback, but I will try to fix outright errors. Since it was primarily created to fit our way of working within our organization it may very well not be to everyone's liking. Take it or leave it basically.

**REQUIREMENTS**

As far as I am aware it will work with Lucee all the way down to 4.5.
For Adobe Coldfusion you'll need atleast 10+ although I am not 100% sure.
I developed this against Adobe Coldfusion 2016 and I have not paid special attention to what newer features I've used.

As far as folder structure goes there are two requirements: 

**1:** All the CFCs from here are in a subfolder directly under the Application-root called "Components".

**2:** The webdriver binaries for running Selenium locally must be in a subfolder directly under the Application-root called "WebdriverBins".

The reason for the mappings requirement is simple: I struggled with trying to maintain two separate versions of the code (for work and for public use here on GitHub) so all the code is straight from my work versions. Sorry about that. You'll have to fork and/or edit the code yourself if you want to get rid of the reliance on my mappings.

**SETTING UP**

The **WebdriverManager.cfc** is the interface for creating the webdriver (which I call a Browser) and optionally a service (which is not abstracted, it's the original Selenium Java object). The simplest example for creating a webdriver for Chrome would look like this:
```
<cfset Browser = createObject('component', 'Components.WebDriverManager').createBrowser(Browser='Chrome') />
```
This would create a local webdriver that runs on your machine, meaning you need to have the webdriver binaries installed on your local. If you are ONLY running your tests remotely (for which you need a server running the Selenium Standalone Server) you can omit installing the webdriver binaries locally.

Alternatively for running on local you could also do this:
```
<cfset Browser = createObject('component', 'Components.WebDriverManager').createBrowser(
	Browser='Chrome',
	Remote=true,
	RemoteServerAddress='http://localhost:9515',
) />
```
Which means you tell the webdriver to execute in remote mode but you point it at your local. In this way you can put your webdriver binaries whereever you want but you need to manually start and close them. For true remote mode you'd point **RemoteServerAddress** at the actual machine running the standalone Selenium server.

The WebdriverManager.cfc is static and is meant to work as a singleton. It doesn't allow you to modify its internal variables and it doesn't rely on them changing at all. So in your own environment you could put it in a (semi)persistent scope and use it to create webdrivers and services.

**USAGE**

I recommend taking a look through the code to see what methods you've got available, and the arguments they accept. Broadly speaking the Browser.cfc is for interacting with the browser and Element.cfc is for interacting with a DOM element.

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

navigateTo() is one of the most obvious ones you'll use a lot, as well as the getElement-methods. quit() closes the browser and ends the session.

**GRABBING ELEMENTS**

As mentioned above the magic of grabbing and interacting with elements happens inside **Browser.cfc**. Here you have two choices:

**1:** Use getElement() or getElements(), which allows you the most specific control over how to target elements or...

**2:** Use getElementBy() which is an interface for ElementLocator.cfc that has easy to use methods for grabbing elements by the most common means, such as ID, class, name, value etc.

getElement() and getElements() structure are identical. The only difference is that the former retrieves a single element whereas the latter returns an array. The syntax is:
```
<cfset AnElement = Browser.getElement()
	searchFor="[name='test']"
	locateUsing=["cssSelector"]
	locateHiddenElements=false
	javascriptArguments=[]
/ >
```
Broken down the arguments are:

- **searchFor (string):** The search string to locate the element by. Can be an id, tag-name, class name, xpath, css selector etc
- **locateUsing (array):** The name(s) of the Selenium locator mechanisms to use. Use this to force using specific mechanism(s). If not passed then it will loop through them in sequence. Valid locators: id,cssSelector,xpath,name,className,linkText,partialLinkText,tagName,javascript.
- **locateHiddenElements (boolean):** Use this to one-time override the default element fetch behaviour regarding returning only elements that are considered visible.
- **javascriptArguments (array):** Used only locateUsing uses "javascript". Script arguments must be a number, a boolean, a string, WebElement, or an array of any of those combinations. The arguments will be made available to the JavaScript via the 'arguments' variable.

getElementBy() is for the most part what you'd use unless you want advanced control over what you're searching for. It contains methods such as:

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

click() and write() are probably the interaction methods you'll use most. click() is selfexplanatory. write() accepts an argument called **text** which may surprise you to learn is an array and not a string. This is how the underlying Java method works as well so I chose to keep it that way. Furthermore, while the Java method by default ADDS to the existing text in an element, my method first clears it and then writes in it. There's a boolean argument to write() called **addToExistingText** to allow it to append the text instead.

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
	SearchFor="button[title^='Add']",
	LocateUsing=["cssSelector"]
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

Don't come expecting a fully fledged framework that will suit all your needs and covers all of Selenium's features. Don't get me wrong: it works and does what it does well, but the goal is just as much to show that it's possible to create a Selenium framework for Coldfusion and offer a working example of how that can be achieved. So feel free to download it, modify, change and extend it as much as possible or just use it as research to figure out how to pull it off yourself.

In general most of the Java interactions are abstracted away and you'll be doing all your calls to Coldfusion objects and code. Although most Java objects are wrapped I have made public methods that can get you the original Java object so that you'll still be able to access all the original Selenium functions directly. I have only wrapped the most commonly used (to me anyway) Selenium methods and functions, which are then exposed via CF methods.

The framework as I present it here it also completely stand-alone. This means I built no support in for reporters, testrunners, or any kind of known (or unknown) test harnesses or frameworks of any kind. You'd have to build that kind of hook yourself.

There's a copious amount of type checking and error handling because that's one of my personal bugbears. Also the framework is liberal about using <cfthrow> when it hits conditions that are considered bad. My aim was to abstract away some of the frankly quite esoteric errors that Selenium occasionally throws and give you clear, concise information about what went wrong so you can easily find and fix it.

**NOTES/TROUBLESHOOTING:**

No outstanding issues that I know of.

**CONTACT AND FEEDBACK:**

I'm always open for comments or feedback, as long as it's constructive. You can reach me at tfrengler@talentsoft.com
