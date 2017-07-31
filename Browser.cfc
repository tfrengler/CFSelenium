<cfcomponent output="false" hint="Coldfusion representation of a browser, primarily acting as a wrapper for Selenium's org.openqa.selenium.remote.RemoteWebDriver class" >
<cfprocessingdirective pageencoding="utf-8" />

	<cfset oJavaWebDriver = createObject("java", "java.lang.Object") />
	<cfset oElementLocator = "" />
	<cfset nWaitForDOMReadyStateTimeOut = 0 />
	<cfset bFetchHiddenElements = false />
	<cfset bUseSeleniumImplicitWait = false />

	<cffunction name="init" returntype="Components.Browser" access="public" hint="Constructor" >
		<cfargument name="WebDriverReference" type="any" required="true" hint="" />
		<cfargument name="WaitForDOMReadyStateTimeOut" type="numeric" required="false" default="30" />

		<cfif isObject(arguments.WebDriverReference) IS false >
			<cfthrow message="Argument 'WebDriverReference' is not an object" />
		</cfif>
		<cfif isInstanceOf(arguments.WebDriverReference, "org.openqa.selenium.remote.RemoteWebDriver") IS false >
			<cfthrow message="Argument 'WebDriverReference' is not an instance of 'org.openqa.selenium.remote.RemoteWebDriver'" />
		</cfif>

		<cfset setElementLocator( 
			Data=createObject("component", "Components.ElementLocator")
				.init(BrowserReference=this) 
			) 
		/>

		<cfset setJavaWebDriver( Data = arguments.WebDriverReference ) />
		<cfset nWaitForDOMReadyStateTimeOut = arguments.WaitForDOMReadyStateTimeOut />

		<cfreturn this />
	</cffunction>

	<cffunction name="useSeleniumImplicitWait" returntype="void" access="public" hint="Use this method to enable or disable Selenium's mechanism for waiting for the DOM elements to be ready. By default our own custom wait mechanism will be used when fetching elements." >
		<cfargument name="Enable" type="boolean" required="yes" hint="Enables or disables Selenium's own built in wait mechanism." />
		<cfargument name="Timeout" type="number" required="false" default=0 hint="The timeout in seconds to wait for the DOM to be ready. Only relevant if you enable this functionality. If you disable it then the implicitlyWait timeout will be to 0 which is default." />

			<cfset var ImplicitTimeout = arguments.Timeout />

			<cfif isValid("integer", arguments.Timeout) IS false >
				<cfthrow message="Argument 'Timeout' must be a valid integer!" />
				<cfif arguments.Timeout LT 0 >
					<cfthrow message="Argument 'Timeout' must be greater than 0!" />
				</cfif>
			</cfif>

			<cfif arguments.Enable IS true >
				<cfset bUseSeleniumImplicitWait = true />
				<cfset ImplicitTimeout = arguments.Timeout />
			<cfelseif arguments.Enable IS false >
				<cfset bUseSeleniumImplicitWait = false />
			</cfif>

			<cfset getJavaWebDriver().manage().timeouts().implicitlyWait(
				javaCast("long", ImplicitTimeout),
				createObject("java", "java.util.concurrent.TimeUnit").SECONDS
			) />
	</cffunction>

	<cffunction name="fetchHiddenElements" returntype="void" access="public" hint="Enable this to make the fetch-methods only return elements that are considered visible. Elements are not visible if their CSS values are set to display: none, visibility: hidden, they are obscured fully or partially behind other elements or they have no width and height." >
		<cfargument name="Value" type="boolean" required="yes" />

		<cfset bFetchHiddenElements = arguments.Value />
	</cffunction>

	<cffunction name="getFetchHiddenElements" returntype="boolean" access="private" >

		<cfreturn bFetchHiddenElements />
	</cffunction>

	<cffunction name="setElementLocator" returntype="void" access="private" >
		<cfargument name="Data" type="Components.ElementLocator" required="yes" />

		<cfset oElementLocator = arguments.Data />
	</cffunction>

	<cffunction name="setJavaWebDriver" returntype="void" access="private" >
		<cfargument name="Data" type="any" required="yes" />

		<cfset oJavaWebDriver = arguments.Data />
	</cffunction>

	<cffunction name="getJavaWebDriver" returntype="any" access="public" hint="Gets you a reference to the Java WebDriver. The reason this is publicly exposed is because not all the Java methods have been interfaced so if you want (and you know what you are doing) you can access them directly." >
		<cfreturn oJavaWebDriver />
	</cffunction>

	<cffunction name="setWaitForDOMReadyStateTimeOut" returntype="void" access="private" >
		<cfargument name="Data" type="numeric" required="yes" />

		<cfset nWaitForDOMReadyStateTimeOut = arguments.Data />
	</cffunction>

	<cffunction name="getWaitForDOMReadyStateTimeOut" returntype="numeric" access="private" >
		<cfreturn nWaitForDOMReadyStateTimeOut />
	</cffunction>

	<cffunction name="getElementBy" returntype="Components.ElementLocator" access="public" hint="Returns an interface that contains shorthand methods designed to quickly grab an element by specific, commonly used attributes such as id, class, title, name etc. If you want to do something more advanced - or just prefer more control - use getElement() or getElements() instead." >
		<cfreturn oElementLocator />
	</cffunction>

	<cffunction name="getElement" returntype="any" access="public" hint="Returns the FIRST element that matches your search criteria. Even if you give it a criteria that matches multiple elements this method will only return the first one it finds and will throw an error if NO elements are found" >
		<cfargument name="SearchFor" type="string" required="true" hint="The search string to locate the element by. Can be an id, tag-name, class name, xpath, css selector etc" />
		<cfargument name="LocateUsing" type="array" required="false" default="#arrayNew(1)#" hint="The name(s) of the Selenium locator mechanisms to use. Use this to force using specific mechanism(s). If not passed then it will loop through them in sequence. Valid locators: id,cssSelector,xpath,name,className,linkText,partialLinkText,tagName" />
		<cfargument name="LocateHiddenElements" type="boolean" required="false" default="#getFetchHiddenElements()#" hint="Use this to one-time override the default element fetch behaviour regarding returning only elements that are considered visible." />

		<cfset var aElementCollection = fetchHTMLElements(
			SearchFor=arguments.SearchFor,
			LocateUsing=arguments.LocateUsing,
			LocateHiddenElements=arguments.LocateHiddenElements
		) />

		<cfif arrayIsEmpty(aElementCollection) >
			<cfthrow message="No element found that matches your criteria. SearchFor: #arguments.SearchFor# | LocateUsing: #arrayToList(arguments.LocateUsing)#" />
		</cfif>

		<cfif isInstanceOf(aElementCollection[1], "Components.Element") IS false >
			<cfthrow message="The first array entry returned from fetchHTMLElements() is not of type 'org.openqa.selenium.remote.RemoteWebElement'.
			Your search criteria were: LocateUsing: #arrayToList(arguments.LocateUsing)# | SearchFor: #arguments.SearchFor#" />
		</cfif>

		<cfreturn aElementCollection[1] />
	</cffunction>

	<cffunction name="getElements" returntype="array" access="public" hint="Returns an array of ALL elements that matches the search criteria. Unlike GetElement() this method will not throw errors if no elements are found." >
		<cfargument name="SearchFor" type="string" required="true" hint="The search string to locate the elements by. Can be an id, tag-name, class name, css selector etc." />
		<cfargument name="LocateUsing" type="array" required="false" default="#arrayNew(1)#" hint="The name(s) of the Selenium locator mechanisms to use. Use this to force using specific mechanism(s). If not passed then it will loop through them in sequence. Valid locators: id,cssSelector,xpath,name,className,linkText,partialLinkText,tagName" />
		<cfargument name="LocateHiddenElements" type="boolean" required="false" default="#getFetchHiddenElements()#" hint="Use this to one-time override the default element fetch behaviour regarding returning only elements that are considered visible." />

		<cfreturn fetchHTMLElements(
			SearchFor=arguments.SearchFor,
			LocateUsing=arguments.LocateUsing,
			LocateHiddenElements=arguments.LocateHiddenElements
		) />
	</cffunction>

	<cffunction name="fetchHTMLElements" returntype="array" access="private" hint="The primary mechanism for getting HTML elements used internally by this component" >
		<cfargument name="SearchFor" type="string" required="true" />
		<cfargument name="LocateUsing" type="array" required="false" />
		<cfargument name="LocateHiddenElements" type="boolean" required="true" />
		<cfargument name="JavascriptArguments" type="array" required="false" default="#arrayNew(1)#" />

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

		<cfif arrayLen(arguments.LocateUsing) GT 0 >

			<cfloop array="#arguments.LocateUsing#" index="sCurrentArgumentLocator" >
				<cfif sCurrentArgumentLocator IS NOT "javascript" AND ArrayContains(aValidSeleniumLocators, sCurrentArgumentLocator) IS false >
					<cfthrow message="Your list of locators passed in argument 'LocateUsing' contains an invalid Selenium locator: #sCurrentArgumentLocator#. Valid locators are: #arrayToList(aValidSeleniumLocators)#" />
				</cfif>
			</cfloop>

			<cfset aValidSeleniumLocators = arguments.LocateUsing /> 
		</cfif>

		<cfloop array="#aValidSeleniumLocators#" index="sCurrentSeleniumLocator" >

			<cfif bUseSeleniumImplicitWait IS false >
				<cfset WaitForDocumentToBeReady() />
			</cfif>

			<cfif sCurrentArgumentLocator IS "javascript" >

				<cfset ReturnDataFromScript = runJavascript(
					Script=arguments.SearchFor,
					Parameters=arguments.JavascriptArguments,
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
					<cfset aElementsFoundInDOM = getJavaWebDriver().findElements(
						invoke(oBy, "#sCurrentSeleniumLocator#", ["#arguments.SearchFor#"])
					) />

				<cfcatch type="org.openqa.selenium.InvalidSelectorException" >

					<cfif ArrayContains(arguments.LocateUsing, "cssSelector") AND findNoCase("An invalid or illegal selector was specified", cfcatch.message) GT 0 >
						
						<cfthrow message="Error fetching element, the selector syntax is invalid" detail="You specified 'cssSelector' in argument 'LocateUsing' but your selector is invalid or illegal: #arguments.SearchFor#" />

					<cfelseif ArrayContains(arguments.LocateUsing, "xpath") AND findNoCase("Unable to locate an element with the xpath expression", cfcatch.message) GT 0 >

						<cfthrow message="Error fetching element, the selector syntax is invalid" detail="You specified 'xpath' in argument 'LocateUsing' but this is not a valid XPath expression: #arguments.SearchFor#" />

					<cfelseif ArrayContains(arguments.LocateUsing, "className") AND findNoCase("An invalid or illegal class name was specified", cfcatch.message) GT 0 >

						<cfthrow message="Error fetching element, the selector syntax is invalid" detail="You specified 'className' in argument 'LocateUsing' but your class name is invalid or illegal: #arguments.SearchFor#" />
					</cfif>

				</cfcatch>
				</cftry>
			</cfif>

			<cfif arrayIsEmpty(aElementsFoundInDOM) IS false >
				<cfloop array="#aElementsFoundInDOM#" index="oCurrentWebElement" >

					<cfif arguments.LocateHiddenElements IS false >

						<cfif oCurrentWebElement.isDisplayed() >	
							<cfset oElement = createObject("component", "Components.Element").init( WebElementReference=oCurrentWebElement ) />
							<cfset arrayAppend(aReturnData, oElement) />
						</cfif>

					<cfelse>
						<cfset oElement = createObject("component", "Components.Element").init( WebElementReference=oCurrentWebElement ) />
						<cfset arrayAppend(aReturnData, oElement) />
					</cfif>

				</cfloop>
				<cfbreak/>
			</cfif>
		</cfloop>

		<cfreturn aReturnData />
	</cffunction>

	<cffunction name="waitForDocumentToBeReady" returntype="void" access="public" hint="This method is used internally to wait for the document to be ready. It checks both the DOM (using the native document.readyState property) and for AJAX calls made with jQuery (checking jQuery.active). It recursively calls itself until the document is ready or until the timeout is reached." >
		<cfargument name="TickCountStart" type="numeric" required="false" default="#getTickCount()#" />

		<cfset sleep(1000) />

		<cfset var nCurrentTickCount = getTickCount() />
		<cfset var bDocumentReadyState = false />
		<cfset var bJQueryReadyState = false />
		<cfset var sDocumentReadyScript = "" />
		<cfset var sJQueryReadyScript = "" />
		<cfset var nTimeDifference = 0 />
		<cfset var nTimeOut = getWaitForDOMReadyStateTimeOut() /> <!--- Be aware that it is not completely accurate. The function's execution time plus the sleep(1000) adds a bit of overhead --->

		<cfset nTimeDifference = numberFormat(nCurrentTickCount/1000,'999') - numberFormat(arguments.TickCountStart/1000,'999') />

		<cfif nTimeDifference GT nTimeOut >
			<cfthrow message="WaitForDocumentToBeReady() hit the timeout before the DOM was ready. Timeout is: <b>#nTimeOut#</b>" />
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

		<cfset bDocumentReadyState = runJavascript(
			Script=sDocumentReadyScript
		) />
		<cfset bJQueryReadyState = runJavascript(
			Script=sJQueryReadyScript
		) />

		<cfif bDocumentReadyState IS true && bJQueryReadyState IS true >
			<!--- End recursion, resume whatever else comes after the call to this function --->
			<cfreturn />
		<cfelse>
			<cfset WaitForDocumentToBeReady(TickCountStart=arguments.TickCountStart) />
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

	<cffunction name="runJavascript" returntype="any" access="public" hint="The script fragment provided will be executed as the body of an anonymous function. Note that local variables will not be available once the script has finished executing, though global variables will persist. If the script returns something Selenium will attempt to convert them. If the script returns nothing or the value is null, then it returns null which makes the variable containing the response undefined." >
		<cfargument name="Script" type="string" required="true" hint="The javascript as a string. Be careful to escape quotes or it will break" />
		<cfargument name="Parameters" type="array" required="false" default="#arrayNew(1)#" hint="Script arguments must be a number, a boolean, a string, WebElement, or an array of any of those combinations. The arguments will be made available to the JavaScript via the 'arguments' variable." />
		<cfargument name="Asynchronous" type="boolean" required="false" default="false" hint="Unlike executing synchronous JavaScript, scripts executed with this method must explicitly signal they are finished by invoking the provided callback. This callback is always injected into the executed function as the last argument." />

		<cfset var ReturnDataFromScript = "" />

		<cfset var aJavascriptArguments = javaCast(
			"java.lang.Object[]",
			arguments.Parameters
		) />

 		<cfif arrayLen(arguments.Parameters) GT 0 >
 			<cfset aJavascriptArguments = javaCast(
				"java.lang.Object[]",
				arguments.Parameters
			) />		
 		</cfif>

 		<cfif arguments.Asynchronous >
			<cfset ReturnDataFromScript = getJavaWebDriver().executeAsyncScript(
				arguments.Script,
				aJavascriptArguments
			) />
		<cfelse>
			<cfset ReturnDataFromScript = getJavaWebDriver().executeScript(
				arguments.Script,
				aJavascriptArguments
			) />
		</cfif>

		<!--- 	If executeScript() does not return something that can be converted then ReturnDataFromScript becomes 'undefined'. Otherwise Selenium converts the results thus:
			
			For an HTML element, returns a WebElement
			For a decimal, a Double is returned
			For a non-decimal number, a Long is returned
			For a boolean, a Boolean is returned
			For all other cases, a String is returned.
			For an array, return a List<Object> with each object following the rules above.
			
			Since executeScript() can potentially return so many different datatypes we return null in case nothing is returned so the caller can react accordingly
		--->
		<cfif isDefined("ReturnDataFromScript") >
			<cfreturn ReturnDataFromScript />
		<cfelse>
			<cfreturn javaCast("null", 0) />
		</cfif>
	</cffunction>

	<cffunction name="takeScreenshot" returntype="any" access="public" hint="Capture a screenshot of the window currently in focus as PNG." >
		<cfargument name="Format" type="string" required="false" default="bytes" hint="The format you want the screenshot returned as. Can return either base64, raw bytes or a java.io.File-object." />

 		<cfset var sValidFormats = "bytes,base64,file" />
 		<cfset var oOutputType = createObject("java", "org.openqa.selenium.OutputType") />
 		<cfset var Type = "" />
 		<cfset var Screenshot = "" />

 		<cfif listFindNoCase(sValidFormats, arguments.Format) GT 0 >

			<cfset Type = oOutputType[ uCase(arguments.Format) ] />
			<cfset Screenshot = getJavaWebDriver().getScreenshotAs(Type) />

		<cfelse>
			<cfthrow message="Argument 'Format' that you passed as '#arguments.Format#' is not a valid format type. Valid formats are: #sValidFormats#" />	
		</cfif>

		<cfreturn Screenshot />
	</cffunction>

</cfcomponent>