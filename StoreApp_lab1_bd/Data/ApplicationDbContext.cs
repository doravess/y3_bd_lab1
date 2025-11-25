using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using StoreApp_lab1_bd.Models;
using System.Data;

namespace StoreApp_lab1_bd.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Product> Products { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Product>().ToTable("Product", "dbo");
            modelBuilder.Entity<Order>().ToTable("Order", "dbo");
            modelBuilder.Entity<OrderItem>().ToTable("OrderItem", "dbo");

            base.OnModelCreating(modelBuilder);
        }

        // Метод для виконання stored procedures, що повертають дані
        public async Task<List<T>> ExecuteStoredProcedureAsync<T>(string procedureName, params SqlParameter[] parameters) where T : class, new()
        {
            var result = new List<T>();
            using (var connection = Database.GetDbConnection())
            {
                await connection.OpenAsync();
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = procedureName;
                    command.CommandType = CommandType.StoredProcedure;

                    if (parameters != null && parameters.Length > 0)
                    {
                        command.Parameters.AddRange(parameters);
                    }

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        var properties = typeof(T).GetProperties();

                        while (await reader.ReadAsync())
                        {
                            var item = new T();
                            foreach (var property in properties)
                            {
                                try
                                {
                                    var ordinal = reader.GetOrdinal(property.Name);
                                    if (!reader.IsDBNull(ordinal))
                                    {
                                        var value = reader.GetValue(ordinal);
                                        var targetType = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
                                        property.SetValue(item, Convert.ChangeType(value, targetType));
                                    }
                                }
                                catch
                                {
                                    // Пропускаємо поля, яких немає в результаті або які не можна змапити
                                }
                            }
                            result.Add(item);
                        }
                    }
                }
            }
            return result;
        }

        // Метод для виконання stored procedures, що не повертають дані (INSERT, UPDATE, DELETE)
        public async Task ExecuteNonQueryStoredProcedureAsync(string procedureName, params SqlParameter[] parameters)
        {
            using (var connection = Database.GetDbConnection())
            {
                await connection.OpenAsync();
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = procedureName;
                    command.CommandType = CommandType.StoredProcedure;

                    if (parameters != null && parameters.Length > 0)
                    {
                        command.Parameters.AddRange(parameters);
                    }

                    await command.ExecuteNonQueryAsync();
                }
            }
        }
    }
}