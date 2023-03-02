var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", new HomeHandler().Execute());
app.MapGet("/doctors", new DoctorsHandler().Execute());

app.Run();
