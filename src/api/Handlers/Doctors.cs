public class DoctorsHandler: IHandler
{
  public RequestDelegate Execute()
  {
    return (context) => {
      var doctors = new List<Doctor>
      {
        new Doctor { Id = 1, Name = "Dr. House" },
        new Doctor { Id = 2, Name = "Dr. Strange" },
        new Doctor { Id = 3, Name = "Dr. Manhattan" },
      };

      return context.Response.WriteAsJsonAsync(doctors);
    };
  }

  private record Doctor
  {
    public int Id { get; set; }
    public string Name { get; set; }
  }
}
