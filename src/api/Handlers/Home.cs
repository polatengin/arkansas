public class HomeHandler: IHandler
{
  public RequestDelegate Execute()
  {
    return (context) => {
      TelemetryHelper.TrackRequest(context);

      TelemetryHelper.TrackEvent(context, "HomeHandler.Execute");

      return context.Response.WriteAsJsonAsync("Hello World!");
    };
  }
}
