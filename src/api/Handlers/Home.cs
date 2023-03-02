public class HomeHandler: IHandler
{
  public RequestDelegate Execute()
  {
    return (context) => {
      return context.Response.WriteAsJsonAsync("Hello World!");
    };
  }
}
