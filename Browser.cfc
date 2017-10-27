<cfcomponent output="false" hint="Coldfusion representation of a browser, acting as a Coldfusion wrapper for Selenium's org.openqa.selenium.remote.RemoteWebDriver-class. Not all Selenium's Java methods are abstracted, but you can still access the original Java object using a public method." >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oJavaWebDriver = createObject("java", "java.lang.Object") />
	<cfset oElementLocator = "" />
	<cfset nWaitForDOMReadyStateTimeOut = 0 />
	<cfset bFetchHiddenElements = false />
	<cfset bUseSeleniumImplicitWait = false />

	<cffunction name="init" returntype="Components.Browser" access="public" hint="Constructor" >
		<cfargument name="webDriverReference" type="any" required="true" hint="" />
		<cfargument name="waitForDOMReadyStateTimeOut" type="numeric" required="false" default="30" />

		<cfif isObject(arguments.WebDriverReference) IS false >
			<cfthrow message="Error when initializing Browser" detail="Argument 'WebDriverReference' is not an object" />
		</cfif>
		<cfif isInstanceOf(arguments.WebDriverReference, "org.openqa.selenium.remote.RemoteWebDriver") IS false >
			<cfthrow message="Error when initializing Browser" detail="Argument 'WebDriverReference' is not an instance of 'org.openqa.selenium.remote.RemoteWebDriver'" />
		</cfif>

		<cfset setElementLocator( 
			Data=createObject("component", "Components.ElementLocator")
				.init(browserReference=this) 
			) 
		/>

		<cfset setJavaWebDriver( Data = arguments.webDriverReference ) />
		<cfset nWaitForDOMReadyStateTimeOut = arguments.waitForDOMReadyStateTimeOut />

		<cfreturn this />
	</cffunction>

	<cffunction name="useSeleniumImplicitWait" returntype="void" access="public" hint="Use this method to enable or disable Selenium's mechanism for waiting for the DOM elements to be ready. By default our own custom wait mechanism will be used when fetching elements." >
		<cfargument name="enable" type="boolean" required="yes" hint="Enables or disables Selenium's own built in wait mechanism." />
		<cfargument name="timeout" type="numeric" required="false" default=0 hint="The timeout in seconds to wait for the DOM to be ready. Only relevant if you enable this functionality. If you disable it then the implicitlyWait timeout will be to 0 which is default." />

			<cfset var nImplicitTimeout = arguments.timeout />

			<cfif isValid("integer", arguments.timeout) IS false >
				<cfthrow message="Error when setting implicit wait" detail="Argument 'Timeout' must be a valid integer!" />
				<cfif arguments.Timeout LT 0 >
					<cfthrow message="Error when setting implicit wait" detail="Argument 'Timeout' must be greater than 0!" />
				</cfif>
			</cfif>

			<cfif arguments.enable IS true >
				<cfset bUseSeleniumImplicitWait = true />
				<cfset nImplicitTimeout = arguments.timeout />
			<cfelseif arguments.enable IS false >
				<cfset bUseSeleniumImplicitWait = false />
				<cfset nImplicitTimeout = 0 />
			</cfif>

			<cfset getJavaWebDriver().manage().timeouts().implicitlyWait(
				javaCast("long", nImplicitTimeout),
				createObject("java", "java.util.concurrent.TimeUnit").SECONDS
			) />
	</cffunction>

	<cffunction name="fetchHiddenElements" returntype="void" access="public" hint="Enable this to make the fetch-methods only return elements that are considered visible. Elements are not visible if their CSS values are set to display: none, visibility: hidden, they are obscured fully or partially behind other elements or they have no width and height." >
		<cfargument name="value" type="boolean" required="yes" />

		<cfset bFetchHiddenElements = arguments.value />
	</cffunction>

	<cffunction name="getFetchHiddenElements" returntype="boolean" access="private" >
		<cfreturn bFetchHiddenElements />
	</cffunction>

	<cffunction name="setElementLocator" returntype="void" access="private" >
		<cfargument name="data" type="Components.ElementLocator" required="yes" />

		<cfset oElementLocator = arguments.data />
	</cffunction>

	<cffunction name="setJavaWebDriver" returntype="void" access="private" >
		<cfargument name="data" type="any" required="yes" />

		<cfset oJavaWebDriver = arguments.data />
	</cffunction>

	<cffunction name="getJavaWebDriver" returntype="any" access="public" hint="Gets you a reference to the Java WebDriver. The reason this is publicly exposed is because not all the Java methods have been abstracted so if you want (and you know what you are doing) you can access them directly." >
		<cfset sleep(100) />
		<cfreturn oJavaWebDriver />
	</cffunction>

	<cffunction name="setWaitForDOMReadyStateTimeOut" returntype="void" access="private" >
		<cfargument name="Data" type="numeric" required="yes" />

		<cfset nWaitForDOMReadyStateTimeOut = arguments.Data />
	</cffunction>

	<cffunction name="getWaitForDOMReadyStateTimeOut" returntype="numeric" access="private" >
		<cfreturn nWaitForDOMReadyStateTimeOut />
	</cffunction>

	<cffunction name="getElementBy" returntype="Components.ElementLocator" access="public" hint="Returns an interface that contains shorthand methods designed to quickly grab elements by specific, commonly used attributes such as id, class, title, name etc. If you want to do something more advanced - or just prefer more control - use getElement() or getElements() instead." >
		<cfreturn oElementLocator />
	</cffunction>

	<cffunction name="getElement" returntype="Components.Element" access="public" hint="Returns the FIRST element that matches your search criteria. Even if you give it a criteria that matches multiple elements this method will only return the first one it finds and will throw an error if NO elements are found." >
		<cfargument name="searchFor" type="string" required="true" hint="The search string to locate the element by. Can be an id, tag-name, class name, xpath, css selector etc" />
		<cfargument name="locateUsing" type="array" required="false" default="#arrayNew(1)#" hint="The name(s) of the Selenium locator mechanisms to use. Use this to force using specific mechanism(s). If not passed then it will loop through them in sequence. Valid locators: id,cssSelector,xpath,name,className,linkText,partialLinkText,tagName,javascript" />
		<cfargument name="locateHiddenElements" type="boolean" required="false" default="#getFetchHiddenElements()#" hint="Use this to one-time override the default element fetch behaviour regarding returning only elements that are considered visible." />

		<cfset var stFetchHTMLElementsArguments = structNew() />
		<cfset var aElementCollection = arrayNew(1) />

		<cfset stFetchHTMLElementsArguments.searchFor = arguments.searchFor />
		<cfset stFetchHTMLElementsArguments.locateUsing = arguments.locateUsing />
		<cfset stFetchHTMLElementsArguments.locateHiddenElements = arguments.locateHiddenElements />

		<cfif 	structKeyExists(arguments, "searchContext") AND
				isObject(arguments.searchContext) AND
				isInstanceOf(arguments.searchContext, "org.openqa.selenium.remote.RemoteWebElement") >
			
			<cfset stFetchHTMLElementsArguments.searchContext = arguments.searchContext />
		</cfif>

		<cfset aElementCollection = fetchHTMLElements(argumentCollection = stFetchHTMLElementsArguments) />

		<cfif arrayIsEmpty(aElementCollection) >
			<cfthrow message="Error fetching HTML element" detail="No element found that matches your criteria. SearchFor: #arguments.searchFor# | LocateUsing: #arrayToList(arguments.locateUsing)#" />
		</cfif>

		<cfif isInstanceOf(aElementCollection[1], "Components.Element") IS false >
			<cfthrow message="Error fetching HTML element" detail="The first array entry returned from fetchHTMLElements() is not of type 'org.openqa.selenium.remote.RemoteWebElement'.
			Your search criteria were: LocateUsing: #arrayToList(arguments.locateUsing)# | SearchFor: #arguments.searchFor#" />
		</cfif>

		<cfreturn aElementCollection[1] />
	</cffunction>

	<cffunction name="getElements" returntype="array" access="public" hint="Returns an array of ALL elements that matches the search criteria. Unlike GetElement() this method will not throw errors if no elements are found, so it's good to use for checking the existence of an element." >
		<cfargument name="searchFor" type="string" required="true" hint="The search string to locate the elements by. Can be an id, tag-name, class name, css selector etc." />
		<cfargument name="locateUsing" type="array" required="false" default="#arrayNew(1)#" hint="The name(s) of the Selenium locator mechanisms to use. Use this to force using specific mechanism(s). If not passed then it will loop through them in sequence. Valid locators: id,cssSelector,xpath,name,className,linkText,partialLinkText,tagName,javascript" />
		<cfargument name="locateHiddenElements" type="boolean" required="false" default="#getFetchHiddenElements()#" hint="Use this to one-time override the default element fetch behaviour regarding returning only elements that are considered visible." />

		<cfset var stFetchHTMLElementsArguments = structNew() />
		<cfset var aElementCollection = arrayNew(1) />

		<cfset stFetchHTMLElementsArguments.searchFor = arguments.searchFor />
		<cfset stFetchHTMLElementsArguments.locateUsing = arguments.locateUsing />
		<cfset stFetchHTMLElementsArguments.locateHiddenElements = arguments.locateHiddenElements />

		<cfif 	structKeyExists(arguments, "searchContext") AND
				isObject(arguments.searchContext) AND
				isInstanceOf(arguments.searchContext, "org.openqa.selenium.remote.RemoteWebElement") >
			
			<cfset stFetchHTMLElementsArguments.searchContext = arguments.searchContext />
		</cfif>

		<cfset aElementCollection = fetchHTMLElements(argumentCollection = stFetchHTMLElementsArguments) />

		<cfreturn aElementCollection />
	</cffunction>

	<cffunction name="fetchHTMLElements" returntype="array" access="private" hint="The primary mechanism for getting HTML elements used internally by this component." >
		<cfargument name="searchFor" type="string" required="true" />
		<cfargument name="locateUsing" type="array" required="false" />
		<cfargument name="locateHiddenElements" type="boolean" required="true" />
		<cfargument name="searchContext" type="any" required="false" default="#getJavaWebDriver()#" hint="A reference to a Selenium Java-object, either the WebDriver, or a WebElement. This is the context in which the browser searches for elements. Normally this would be the browser/webdriver itself (within the document-node) but you can also search within DOM-elements using Selenium, just like you can in Javascript." />
		<cfargument name="javascriptArguments" type="array" required="false" default="#arrayNew(1)#" />

		<cfset var aReturnData = arrayNew(1) />
		<cfset var oCurrentWebElement = "" />
		<cfset var oElement = "" />
		<cfset var CurrentJavascriptReturnData = "" />
		<cfset var sCurrentSeleniumLocator = "" />
		<cfset var sCurrentArgumentLocator = "" />
		<cfset var ReturnDataFromScript = "" />
		<cfset var aElementsFoundInDOM = arrayNew(1) />
		<cfset var oBy = createObject("java", "org.openqa.selenium.By") />
		<cfset var aValidSeleniumLocators = [ 
			"id",
			"cssSelector",
			"xpath",
			"name",
			"className",
			"linkText",
			"partialLinkText",
			"tagName"
		] />
		<!--- 
			These are in order of priority and if LocateUsing is not defined it will loop through these and stop as soon as an element or elements are found.
			The priority is based on: 1) locaters that are often used and: 2) on locaters that return only a single elements first, multiple elements second.
		--->

		<cfif isObject(arguments.searchContext) IS false >
			<cfthrow message="Error fetching HTML element(s)" detail="Argument 'searchContext' is not an object" />
		</cfif>

		<cfif arrayLen(arguments.locateUsing) GT 0 >

			<cfloop array="#arguments.locateUsing#" index="sCurrentArgumentLocator" >
				<cfif sCurrentArgumentLocator IS NOT "javascript" AND ArrayContains(aValidSeleniumLocators, sCurrentArgumentLocator) IS false >
					<cfthrow message="Error fetching HTML element(s)" detail="Your list of locators passed in argument 'LocateUsing' contains an invalid Selenium locator: #sCurrentArgumentLocator#. Valid locators are: #arrayToList(aValidSeleniumLocators)#" />
				</cfif>
			</cfloop>

			<cfset aValidSeleniumLocators = arguments.locateUsing /> 
		</cfif>

		<cfloop array="#aValidSeleniumLocators#" index="sCurrentSeleniumLocator" >

			<cfif bUseSeleniumImplicitWait IS false >
				<cfset variables.waitForDocumentToBeReady() />
			</cfif>

			<cfif sCurrentArgumentLocator IS "javascript" >

				<cfset ReturnDataFromScript = runJavascript(
					Script="#arguments.searchFor#",
					Parameters=arguments.javascriptArguments,
					Asynchronous=false
				) />

				<cfif isDefined("ReturnDataFromScript") >

					<cfif isArray(ReturnDataFromScript) >

						<cfloop array="#ReturnDataFromScript#" index="CurrentJavascriptReturnData" >
							<cfif isObject(CurrentJavascriptReturnData) AND isInstanceOf(CurrentJavascriptReturnData, "org.openqa.selenium.remote.RemoteWebElement") >
								<cfset arrayAppend( aElementsFoundInDOM, CurrentJavascriptReturnData ) />
							</cfif>
						</cfloop>

					<cfelse>

						<cfif isObject(ReturnDataFromScript) AND isInstanceOf(ReturnDataFromScript, "org.openqa.selenium.remote.RemoteWebElement") >
							<cfset arrayAppend( aElementsFoundInDOM, ReturnDataFromScript ) />
						</cfif>
					</cfif>
				</cfif>

			<cfelse>

				<cftry>
					<cfset aElementsFoundInDOM = arguments.searchContext.findElements(
						invoke(oBy, "#sCurrentSeleniumLocator#", ["#arguments.searchFor#"])
					) />

				<cfcatch type="org.openqa.selenium.InvalidSelectorException" >

					<cfif ArrayContains(arguments.locateUsing, "cssSelector") AND findNoCase("An invalid or illegal selector was specified", cfcatch.message) GT 0 >
						
						<cfthrow message="Error fetching HTML element(s), the selector syntax is invalid" detail="You specified 'cssSelector' in argument 'LocateUsing' but your selector is invalid or illegal: #arguments.searchFor#" />

					<cfelseif ArrayContains(arguments.locateUsing, "xpath") AND findNoCase("Unable to locate an element with the xpath expression", cfcatch.message) GT 0 >

						<cfthrow message="Error fetching HTML element(s), the selector syntax is invalid" detail="You specified 'xpath' in argument 'LocateUsing' but this is not a valid XPath expression: #arguments.searchFor#" />

					<cfelseif ArrayContains(arguments.locateUsing, "className") AND findNoCase("An invalid or illegal class name was specified", cfcatch.message) GT 0 >

						<cfthrow message="Error fetching HTML element(s), the selector syntax is invalid" detail="You specified 'className' in argument 'LocateUsing' but your class name is invalid or illegal: #arguments.searchFor#" />
					</cfif>

				</cfcatch>
				</cftry>
			</cfif>

			<cfif arrayIsEmpty(aElementsFoundInDOM) IS false >
				<cfloop array="#aElementsFoundInDOM#" index="oCurrentWebElement" >

					<cfif arguments.locateHiddenElements IS false >

						<cfif oCurrentWebElement.isDisplayed() >	
							<cfset oElement = createObject("component", "Components.Element").init( 
								webElementReference=oCurrentWebElement,
								browserReference=this
							) />
							<cfset arrayAppend(aReturnData, oElement) />
						</cfif>

					<cfelse>
						<cfset oElement = createObject("component", "Components.Element").init( 
							webElementReference=oCurrentWebElement,
							browserReference=this
						) />
						<cfset arrayAppend(aReturnData, oElement) />
					</cfif>

				</cfloop>
				<cfbreak/>
			</cfif>
		</cfloop>

		<cfreturn aReturnData />
	</cffunction>

	<cffunction name="waitForDocumentToBeReady" returntype="void" access="public" hint="This method is used internally to wait for the document to be ready. It checks both the DOM (using the native document.readyState property) and for AJAX calls made with jQuery (checking jQuery.active). It recursively calls itself until the document is ready or until the timeout is reached." >
		<cfargument name="tickCountStart" type="numeric" required="false" default="#getTickCount()#" />

		<cfset sleep(100) />

		<cfset var nCurrentTickCount = getTickCount() />
		<cfset var bDocumentReadyState = false />
		<cfset var bJQueryReadyState = false />
		<cfset var sDocumentReadyScript = "" />
		<cfset var sJQueryReadyScript = "" />
		<cfset var nTimeDifference = 0 />
		<cfset var aJavascriptArguments = javaCast("java.lang.Object[]", arrayNew(1)) />
		<cfset var nTimeOut = getWaitForDOMReadyStateTimeOut() /> <!--- Be aware that it is not completely accurate. The function's execution time plus the sleep(100) adds a bit of overhead --->

		<cfset nTimeDifference = numberFormat(nCurrentTickCount/1000,'999') - numberFormat(arguments.tickCountStart/1000,'999') />

		<cfif nTimeDifference GT nTimeOut >
			<cfthrow message="Error while waiting for DOM to get ready" detail="WaitForDocumentToBeReady() hit the timeout before the DOM was ready. Timeout is: #nTimeOut#" />
			<cfreturn />
		</cfif>

		<cfsavecontent variable="sDocumentReadyScript">
			var sDocumentState = document.readyState;
			if (sDocumentState === "complete") {
				return true
			}
			else {
				return false;
			};
		</cfsavecontent>

		<cfsavecontent variable="sJQueryReadyScript" >
			if (typeof jQuery === "undefined") {
				return true;
			};

			var nJQueryState = jQuery.active;
			if (nJQueryState === 0) {
				return true
			}
			else {
				return false;
			};
		</cfsavecontent>
		
		<cfset bDocumentReadyState = getJavaWebDriver().executeScript(
			sDocumentReadyScript,
			aJavascriptArguments
		) />
		<cfset bJQueryReadyState = getJavaWebDriver().executeScript(
			sJQueryReadyScript,
			aJavascriptArguments
		) />

		<cfif bDocumentReadyState IS true AND bJQueryReadyState IS true >
			<!--- End recursion, resume whatever else comes after the call to this function --->
			<cfreturn />
		<cfelse>
			<cfset WaitForDocumentToBeReady(TickCountStart=arguments.tickCountStart) />
		</cfif>
	</cffunction>

	<cffunction name="navigateTo" returntype="void" access="public" hint="Load a new web page in the current browser window." >
		<cfargument name="URL" type="string" required="true" />

		<cftry>
			<cfset createObject("java", "java.net.URL").init( arguments.URL ) />

			<cfcatch type="java.net.MalformedURLException">
				<cfthrow message="Error navigating to URL" detail="Either no legal protocol could be found in argument 'URL' or it could not be parsed as a URL. What you passed was: #arguments.URL#" />
			</cfcatch>
		</cftry>

		<cfset getJavaWebDriver().get( arguments.URL ) />
	</cffunction>

	<cffunction name="quit" returntype="void" access="public" hint="Quits this driver, closing every associated window." >
		<cfreturn getJavaWebDriver().quit() />
	</cffunction>

	<cffunction name="close" returntype="void" access="public" hint="Close the current window, quitting the browser if it's the last window currently open." >
		<cfreturn getJavaWebDriver().close() />
	</cffunction>

	<cffunction name="runJavascript" returntype="any" access="public" hint="The script fragment provided will be executed as the body of an anonymous function. Note that local variables will not be available once the script has finished executing, though global variables will persist. If the script returns something Selenium will attempt to convert them. If the script returns nothing or the value is null, then it returns null which makes the variable containing the response undefined." >
		<cfargument name="script" type="string" required="true" hint="The javascript as a string. Be careful to escape quotes or it will break" />
		<cfargument name="parameters" type="array" required="false" default="#arrayNew(1)#" hint="Script arguments must be a number, a boolean, a string, WebElement, or an array of any of those combinations. The arguments will be made available to the JavaScript via the 'arguments' variable." />
		<cfargument name="asynchronous" type="boolean" required="false" default="false" hint="Unlike executing synchronous JavaScript, scripts executed with this method must explicitly signal they are finished by invoking the provided callback. This callback is always injected into the executed function as the last argument." />
		
		<cfset var ReturnDataFromScript = "" />

		<cfset var aJavascriptArguments = javaCast(
			"java.lang.Object[]",
			arguments.parameters
		) />

		<cfset waitForDocumentToBeReady() />

 		<cfif arguments.Asynchronous >
			<cfset ReturnDataFromScript = getJavaWebDriver().executeAsyncScript(
				arguments.script,
				aJavascriptArguments
			) />
		<cfelse>
			<cfset ReturnDataFromScript = getJavaWebDriver().executeScript(
				arguments.script,
				aJavascriptArguments
			) />
		</cfif>

		<!--- 	
			If executeScript() does not return something that can be converted then ReturnDataFromScript becomes 'undefined'. 
			Otherwise Selenium converts the results thus:
			
			For an HTML element, returns a WebElement
			For a decimal, a Double is returned
			For a non-decimal number, a Long is returned
			For a boolean, a Boolean is returned
			For all other cases, a String is returned.
			For an array, return a List<Object> with each object following the rules above.
			
			Since executeScript() can potentially return so many different datatypes we return null in case nothing is 
			returned so the caller can react accordingly.

			If an element isn't returned from this method, and you try to call methods on the result, you'll like get an 
			error along the lines of this: "Value must be initialized before use. Its possible that a method called on a 
			Java object created by CreateObject returned null."
		--->
		
		<cfif isDefined("ReturnDataFromScript") >
			<cfreturn ReturnDataFromScript />
		<cfelse>
			<cfreturn javaCast("null", 0) />
		</cfif>
	</cffunction>

	<cffunction name="takeScreenshot" returntype="any" access="public" hint="Capture a screenshot of the window currently in focus as PNG." >
		<cfargument name="format" type="string" required="false" default="bytes" hint="The format you want the screenshot returned as. Can return either base64, raw bytes or a java.io.File-object. Valid parameter strings are: 'bytes', 'base64' or 'file'." />

 		<cfset var sValidFormats = "bytes,base64,file" />
 		<cfset var oOutputType = createObject("java", "org.openqa.selenium.OutputType") />
 		<cfset var Type = "" />
 		<cfset var Screenshot = "" />

 		<cfif listFindNoCase(sValidFormats, arguments.format) GT 0 >

			<cfset Type = oOutputType[ uCase(arguments.format) ] />
			<cfset Screenshot = getJavaWebDriver().getScreenshotAs(Type) />

		<cfelse>
			<cfthrow message="Error taking screenshot" detail="Argument 'Format' that you passed as '#arguments.format#' is not a valid format type. Valid formats are: #sValidFormats#" />	
		</cfif>

		<cfreturn Screenshot />
	</cffunction>

</cfcomponent>