<cfcomponent modifier="final" output="false" persistent="true" hint="" >

	<cfproperty name="DefaultTimeout"		type="numeric"    				getter="false"	setter="false" hint="" />
	<cfproperty name="DefaultInterval"		type="numeric"    				getter="false"	setter="false" hint="" />
	<cfproperty name="IsClickableScript"	type="string"    				getter="false"	setter="false" hint="" />
	<cfproperty name="IsVisibleScript"		type="string"    				getter="false"	setter="false" hint="" />
	<cfproperty name="IsInvisibleScript"	type="string"    				getter="false"	setter="false" hint="" />
	<cfproperty name="SeleniumFactory"		type="SeleniumObjectFactory"	getter="false"	setter="false" hint="" />

	<cffunction name="until" returntype="WaitResult" access="public" hint="Utility method for waiting until a specific condition is deemed true. The retry method should return whatever result you are expecting, with the check method validating the result." >
		<cfargument name="retryMethod" type="Function" required="true" hint="The method which is repeatedly retried. The return data could be anything (even void or null, though that'd be useless)." />
		<cfargument name="checkMethod" type="Function" required="true" hint="The method which verifies that the return data from the retry method is what is expected. Is expected to return a boolean value." />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)." />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry- and check-method. If set to false then after the first exception, the WaitResult is returned, regardless of the timeout." />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw as soon as an exception is thrown by the retry- or check-method. This takes precedence over 'ignoreExceptions'." />
		
		<cfscript>
		var ReturnData = new WaitResult();
		var Result = null;
		var StartTime = getTickCount();

		while (true) {
			ReturnData.Iterate();
			try {
				Result = arguments.retryMethod();
				if (!isNull(Result) AND arguments.checkMethod(Result) IS true)
					return ReturnData.Finish(value=Result);
			}
			catch(any exception) {
				ReturnData.SetLastException(exception);
				if (arguments.throwOnException) rethrow;
				if (!arguments.ignoreExceptions) return ReturnData.Finish(); 
			};

			if (getTickCount() - StartTime > arguments.timeout) 
				return ReturnData.Finish(timedOut=true);

			sleep(variables.DefaultInterval);
		}
		</cfscript>
	</cffunction>

	<cffunction name="untilTrue" returntype="WaitResult" access="public" hint="Utility method for waiting until a certain condition is considered true" >
		<cfargument name="retryMethod" type="Function" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)." />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry- and check-method. If set to false then after the first exception, the WaitResult is returned, regardless of the timeout." />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw as soon as an exception is thrown by the retry- or check-method. This takes precedence over 'ignoreExceptions'." />
		
		<cfreturn variables.Until(arguments.retryMethod, (required boolean data)=> data == true, arguments.timeout, arguments.ignoreExceptions, arguments.throwOnException) />
	</cffunction>

	<cffunction name="untilFalse" returntype="WaitResult" access="public" hint="Utility method for waiting until a certain condition is considered false" >
		<cfargument name="retryMethod" type="Function" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)." />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry- and check-method. If set to false then after the first exception, the WaitResult is returned, regardless of the timeout." />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw as soon as an exception is thrown by the retry- or check-method. This takes precedence over 'ignoreExceptions'." />

		<cfreturn variables.Until(arguments.retryMethod, (required boolean data)=> data == false, arguments.timeout, arguments.ignoreExceptions, arguments.throwOnException) />
	</cffunction>

	<cffunction name="untilElementLocatedByIsVisible" returntype="WaitResult" access="public" hint="Waits until an element defined by the locator passed is considered visible. WaitResult.Value will contain the element." >
		<cfargument name="browser" type="Browser" required="true" />
		<cfargument name="locator" type="Locator" required="true" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)." />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry- and check-method. If set to false then after the first exception, the WaitResult is returned, regardless of the timeout." />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw as soon as an exception is thrown by the retry- or check-method. This takes precedence over 'ignoreExceptions'." />

		<cfscript> 
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var JavaLocator = arguments.locator.getSeleniumLocator();

		return variables.Until(
			()=> JavaBrowser.findElement(JavaLocator),
			(any webElement)=> JavaBrowser.executeScript(variables.IsVisibleScript, [arguments.webElement]),
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="untilElementIsVisible" returntype="WaitResult" access="public" hint="Waits until an element passed in is considered visible. WaitResult.Value will contain the element." >
		<cfargument name="browser" type="Browser" required="true" />
		<cfargument name="element" type="Element" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)." />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry- and check-method. If set to false then after the first exception, the WaitResult is returned, regardless of the timeout." />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw as soon as an exception is thrown by the retry- or check-method. This takes precedence over 'ignoreExceptions'." />

		<cfscript> 
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var Element = arguments.element;

		return variables.Until(
			()=> Element,
			(any webElement)=> JavaBrowser.executeScript(variables.IsVisibleScript, [arguments.webElement.getJavaWebElement()]),
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="untilElementLocatedByIsInvisible" returntype="WaitResult" access="public" hint="Waits until an element defined by the locator passed is considered invisible. WaitResult.Value will contain the element." >
		<cfargument name="browser" type="Browser" required="true" />
		<cfargument name="locator" type="Locator" required="true" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)." />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry- and check-method. If set to false then after the first exception, the WaitResult is returned, regardless of the timeout." />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw as soon as an exception is thrown by the retry- or check-method. This takes precedence over 'ignoreExceptions'." />

		<cfscript> 
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var JavaLocator = arguments.locator.getSeleniumLocator();

		return variables.Until(
			()=> JavaBrowser.findElement(JavaLocator),
			(any webElement)=> JavaBrowser.executeScript(variables.IsInvisibleScript, [arguments.webElement]),
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="untilElementIsInvisible" returntype="WaitResult" access="public" hint="Waits until an element passed in is considered invisible. WaitResult.Value will contain the element." >
		<cfargument name="browser" type="Browser" required="true" />
		<cfargument name="element" type="Element" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)." />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry- and check-method. If set to false then after the first exception, the WaitResult is returned, regardless of the timeout." />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw as soon as an exception is thrown by the retry- or check-method. This takes precedence over 'ignoreExceptions'." />

		<cfscript> 
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var Element = arguments.element;

		return variables.Until(
			()=> Element,
			(any webElement)=> JavaBrowser.executeScript(variables.IsInvisibleScript, [arguments.webElement.getJavaWebElement()]),
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="untilElementIsClickable" returntype="WaitResult" access="public" hint="Waits until an element passed in is considered clickable. WaitResult.Value will contain the element." >
		<cfargument name="browser" type="Browser" required="true" />
		<cfargument name="element" type="Element" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)." />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry- and check-method. If set to false then after the first exception, the WaitResult is returned, regardless of the timeout." />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw as soon as an exception is thrown by the retry- or check-method. This takes precedence over 'ignoreExceptions'." />

		<!---
			Conditions for clickability (according to Selenium):
			1: Element must be in viewport
			2: Element must be visible (display and visibility attributes are inspected)
			3: Element must be enabled (disabled attribute is inspected)
			4: Element must have dimensions (larger than 0 pixels)
		--->
		<cfscript> 
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var Element = arguments.element;

		return variables.Until(
			()=> Element,
			(any webElement)=> JavaBrowser.executeScript(variables.IsClickableScript, [arguments.webElement.getJavaWebElement()]),
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="untilElementLocatedByIsPresent" returntype="WaitResult" access="public" hint="Waits until an element defined by the locator passed is present (existsing, as in attached to the DOM). WaitResult.Value will contain the element." >
		<cfargument name="browser" type="Browser" required="true" />
		<cfargument name="locator" type="Locator" required="true" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)." />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry- and check-method. If set to false then after the first exception, the WaitResult is returned, regardless of the timeout." />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw as soon as an exception is thrown by the retry- or check-method. This takes precedence over 'ignoreExceptions'." />

		<cfscript> 
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var JavaLocator = arguments.locator.getSeleniumLocator();

		return variables.Until(
			()=> JavaBrowser.findElement(JavaLocator),
			(any webElement)=> webElement.getClass().name IS "org.openqa.selenium.remote.RemoteWebElement",
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="init" returntype="Wait" access="public" hint="Constructor" >
		<cfargument name="seleniumFactory" type="SeleniumObjectFactory" required="true" />
		<cfargument name="useStrictVisibilityCheck" type="boolean" required="false" default="false" hint="Whether to use a stricter ruleset for what is considered visible (what Selenium adheres to). This setting is used for ALL methods during the lifetime of the instance." />

		<cfset variables.SeleniumFactory = arguments.seleniumFactory />
		<cfset variables.DefaultTimeout = 1000 />
		<cfset variables.DefaultInterval = 300 />
		<cfset variables.IsClickableScript = null />
		<cfset variables.IsVisibleScript = null />
		<cfset variables.IsInvisibleScript = null />

		<cfsavecontent variable="variables.IsClickableScript" >
			const element = arguments[0];
			const rect = element.getBoundingClientRect();
		
			return (
				<cfif arguments.useStrictVisibilityCheck >
				(rect.top >= 0 &&
				rect.left >= 0 &&
				rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
				rect.right <= (window.innerWidth || document.documentElement.clientWidth)) &&
				</cfif>
				element.style.visibility !== "hidden"
				&& element.style.display !== "none"
				&& element.disabled != true
				&& (rect.width > 0 && rect.height > 0)
			);
		</cfsavecontent>

		<cfsavecontent variable="variables.IsVisibleScript" >
			const element = arguments[0];
			const rect = element.getBoundingClientRect();
		
			return (
				<cfif arguments.useStrictVisibilityCheck >
				(rect.top >= 0 &&
				rect.left >= 0 &&
				rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
				rect.right <= (window.innerWidth || document.documentElement.clientWidth)) &&
				</cfif>
				element.style.visibility !== "hidden"
				&& element.style.display !== "none"
				&& (rect.width > 0 && rect.height > 0)
			);
		</cfsavecontent>
	
		<cfsavecontent variable="variables.IsInvisibleScript" >
			const element = arguments[0];
			const rect = element.getBoundingClientRect();
		
			return (
				<cfif arguments.useStrictVisibilityCheck >
				!(rect.top >= 0 &&
				rect.left >= 0 &&
				rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
				rect.right <= (window.innerWidth || document.documentElement.clientWidth)) ||
				</cfif>
				element.style.visibility === "hidden"
				|| element.style.display === "none"
				|| (rect.width === 0 && rect.height === 0)
			);
		</cfsavecontent>
	</cffunction>
</cfcomponent>