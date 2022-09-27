//This file is an example protocl which will read a script command from the socket and execute it
// information about what happened is returned 

funcdef void ScriptDelegate();

class ScriptTool
{
	Network::WebSocket me;

	[190]
	void OnOpened()	{ Println("Open Socket"); }

	[191]
	void OnClosed(Network::Closed )	{ Println("Closed Socket"); me.kill();	}

	[192]
	void OnError(Network::Error) { Println("Connetion Error"); }

	[193]
	void OnMessageRecieved(dictionary@ message)
	{
		if(message is null)
		{
			LOG_F(0, "Script Tool: Got empty message");
			return;
		}

		string script;
		if(!message.get("script", script))
		{
			LOG_F(0, "Script tool: Expected script, protocol bad?");
			return;
		}

		string error_log;
		script = string("void my_function() {\n", script, "\n}");
		ScriptDelegate@ result = null;

		if(!CompileDelegate(@result, script, error_log))
		{
					me.send({{"compileStatus", false}, {"executionStatus", false}, {"error", error_log }});
					return;
		}

		try
		{
				result();
				me.send({{"compileStatus", true}, {"executionStatus", true}, {"error", "" }});
		}
		catch
		{
				me.send({{"compileStatus", true}, {"executionStatus", false}, {"error", GetExceptionString() }});
		}
	}
}
