<cfcomponent modifier="final" output="false" hint="" >

	<cfset variables.DefaultTimeout = 1000 />
	<cfset variables.DefaultInterval = 300 />
	<cfset variables.SeleniumFactory = null />
	<cfset variables.StrictVisibilityCheck = false /> 

	<cfsavecontent variable="variables.IsVisibleScript" >
		const element = arguments[0];
		const rect = element.getBoundingClientRect();
	
		return (
			<cfif variables.StrictVisibilityCheck >
			(rect.top >= 0 &&
			rect.left >= 0 &&
			rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
			rect.right <= (window.innerWidth || document.documentElement.clientWidth)) &&
			</cfif>
			&& element.style.visibility !== "hidden"
			&& element.style.display !== "none"
			&& (rect.width > 0 && rect.height > 0)
		);
	</cfsavecontent>

	<cfsavecontent variable="variables.IsInvisibleScript" >
		const element = arguments[0];
		const rect = element.getBoundingClientRect();
	
		return (
			<cfif variables.StrictVisibilityCheck >
			!(rect.top >= 0 &&
			rect.left >= 0 &&
			rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
			rect.right <= (window.innerWidth || document.documentElement.clientWidth)) &&
			</cfif>
			|| element.style.visibility === "hidden"
			|| && element.style.display === "none"
			|| (rect.width === 0 && rect.height === 0)
		);
	</cfsavecontent>

	<cffunction name="until" returntype="WaitResult" access="public" hint="XXX" >
		<cfargument name="retryMethod" type="Function" required="true" hint="The method which is repeatedly retried" />
		<cfargument name="checkMethod" type="Function" required="true" hint="The method which checks that the return data from the retry method is correct" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)" />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry method" />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw an exception on the first exception thrown" />
		
		<cfscript>
		var ReturnData = new WaitResult();
		var Result = null;
		var StartTime = getTickCount();

		while (true) {
			ReturnData.Iterate();
			try {
				Result = arguments.retryMethod();
			}
			catch(any exception) {
				ReturnData.SetException(exception);
				if (arguments.throwOnException) rethrow;
				if (!arguments.ignoreExceptions) return ReturnData.Finish(); 
			};

			if (!isNull(Result) AND arguments.checkMethod(Result) IS true)
				return ReturnData.Finish(timedOut=false, value=Result);

			if (getTickCount() - StartTime > arguments.timeout) 
				return ReturnData.Finish(timedOut=true);

			sleep(variables.DefaultInterval);
		}
		</cfscript>
	</cffunction>

	<cffunction name="untilTrue" returntype="WaitResult" access="public" hint="XXX" >
		<cfargument name="retryMethod" type="Function" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="The time to keep trying the retry method before timing out (in ms)" />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry method" />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw an exception on the first exception thrown" />
		
		<cfreturn variables.Until(arguments.retryMethod, (required boolean data)=> data == true, arguments.timeout, arguments.ignoreExceptions, arguments.throwOnException) />
	</cffunction>

	<cffunction name="untilFalse" returntype="WaitResult" access="public" hint="XXX" >
		<cfargument name="retryMethod" type="Function" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="" />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry method" />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw an exception on the first exception thrown" />

		<cfreturn variables.Until(arguments.retryMethod, (required boolean data)=> data == false, arguments.timeout, arguments.ignoreExceptions, arguments.throwOnException) />
	</cffunction>

	<cffunction name="untilElementLocatedByIsVisible" returntype="WaitResult" access="public" hint="XXX" >
		<cfargument name="browser" type="Browser" required="true" hint="" />
		<cfargument name="locator" type="Locator" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="" />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry method" />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw an exception on the first exception thrown" />

		<cfscript> 
		//These are necessary because referring to the arguments-scope inside a closure refers to the closure's arguments...
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var JavaLocator = arguments.locator.getSeleniumLocator();

		return variables.UntilTrue(
			()=> {
				var element = JavaBrowser.getJavaWebDriver().findElement(JavaLocator);
				return local_browser.runJavascript(script=variables.IsVisibleScript, parameters=[element])
			},
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="untilElementIsVisible" returntype="XXX" access="public" hint="XXX" >
		<cfargument name="browser" type="Browser" required="true" hint="" />
		<cfargument name="element" type="Element" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="" />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry method" />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw an exception on the first exception thrown" />

		<cfscript> 
		//These are necessary because referring to the arguments-scope inside a closure refers to the closure's arguments...
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var JavaElement = arguments.locator.getJavaWebElement();

		return variables.UntilTrue(
			()=> JavaBrowser.runJavascript(script=variables.IsVisibleScript, parameters=[JavaElement]),
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="untilElementLocatedByIsInvisible" returntype="WaitResult" access="public" hint="XXX" >
		<cfargument name="browser" type="Browser" required="true" hint="" />
		<cfargument name="locator" type="Locator" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="" />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry method" />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw an exception on the first exception thrown" />

		<cfscript> 
		//These are necessary because referring to the arguments-scope inside a closure refers to the closure's arguments...
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var JavaLocator = arguments.locator.getSeleniumLocator();

		return variables.UntilTrue(
			()=> {
				var element = JavaBrowser.findElement(JavaLocator);
				return local_browser.runJavascript(script=variables.IsInvisibleScript, parameters=[element])
			},
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="untilElementIsInvisible" returntype="WaitResult" access="public" hint="XXX" >
		<cfargument name="browser" type="Browser" required="true" hint="" />
		<cfargument name="element" type="Element" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="" />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry method" />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw an exception on the first exception thrown" />

		<cfscript> 
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var JavaElement = arguments.locator.getJavaWebElement();

		return variables.UntilTrue(
			()=> JavaBrowser.runJavascript(script=variables.IsInvisibleScript, parameters=[JavaElement]),
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="untilElementIsClickable" returntype="WaitResult" access="public" hint="XXX" >
		<cfargument name="browser" type="Browser" required="true" hint="" />
		<cfargument name="element" type="Element" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="" />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry method" />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw an exception on the first exception thrown" />

		<!---
			Conditions for clickability (according to Selenium):
			1: Element must be in viewport (first 4 rows of code)
			2: Element must be visible
			3: Element must be enabled
			4: Element must have dimensions (larger than 0 pixels)
		--->
		<cfset var IsClickableScript = null />
		<cfsavecontent variable="IsClickableScript" >
			const element = arguments[0];
			const rect = element.getBoundingClientRect();
		
			return (
				(rect.top >= 0 &&
				rect.left >= 0 &&
				rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
				rect.right <= (window.innerWidth || document.documentElement.clientWidth))
				&& element.style.visibility !== "hidden"
				&& element.disabled !== true
				&& (rect.width > 0 && rect.height > 0)
			);
		</cfsavecontent>

		<cfscript> 
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var JavaElement = arguments.element.getJavaWebElement();

		return variables.UntilTrue(
			()=> JavaBrowser.runJavascript(script=IsClickableScript, parameters=[JavaElement]),
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="untilElementLocatedByIsPresent" returntype="WaitResult" access="public" hint="XXX" >
		<cfargument name="browser" type="Browser" required="true" hint="" />
		<cfargument name="locator" type="Locator" required="true" hint="" />
		<cfargument name="timeout" type="numeric" required="false" default=#variables.DefaultTimeout# hint="" />
		<cfargument name="ignoreExceptions" type="boolean" required="false" default="true" hint="Whether to ignore all exceptions thrown by the retry method" />
		<cfargument name="throwOnException" type="boolean" required="false" default="false" hint="Whether to throw an exception on the first exception thrown" />

		<cfscript> 
		var JavaBrowser = arguments.browser.getJavaWebDriver();
		var JavaLocator = arguments.locator.getSeleniumLocator();

		return variables.Until(
			()=> JavaBrowser.getJavaWebDriver().findElement(JavaLocator),
			(any RemoteWebElement)=> isInstanceOf(arguments.element, "org.openqa.selenium.remote.RemoteWebElement"),
			arguments.timeout,
			arguments.ignoreExceptions,
			arguments.throwOnException	
		)
		</cfscript>
	</cffunction>

	<cffunction name="init" returntype="Wait" access="public" hint="Constructor" >
		<cfargument name="seleniumFactory" type="SeleniumObjectFactory" required="true" />
		<cfargument name="useStrictVisibilityCheck" type="boolean" required="false" default="false" />

		<cfset variables.StrictVisibilityCheck = arguments.useStrictVisibilityCheck />
		<cfset variables.SeleniumFactory = arguments.seleniumFactory />
	</cffunction>
</cfcomponent>