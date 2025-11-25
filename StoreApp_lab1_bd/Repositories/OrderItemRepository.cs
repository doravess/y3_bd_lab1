using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using StoreApp_lab1_bd.Data;
using StoreApp_lab1_bd.Models;

namespace YourProject.Repositories
{
    public class OrderItemRepository
    {
        private readonly ApplicationDbContext _context;

        public OrderItemRepository(ApplicationDbContext ctx)
        {
            _context = ctx;
        }

        public async Task<IEnumerable<OrderItem>> GetAllAsync()
        {
            var orderItems = new List<OrderItem>();

            using (var connection = _context.Database.GetDbConnection())
            {
                await connection.OpenAsync();
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "GetOrderItems";
                    command.CommandType = System.Data.CommandType.StoredProcedure;

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            var orderItem = new OrderItem
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                                OrderId = reader.GetInt32(reader.GetOrdinal("OrderId")),
                                ProductId = reader.GetInt32(reader.GetOrdinal("ProductId")),
                                Quantity = reader.GetInt32(reader.GetOrdinal("Quantity")),
                                Price = reader.GetDecimal(reader.GetOrdinal("Price")),
                                Details = reader.IsDBNull(reader.GetOrdinal("Details")) ? null : reader.GetString(reader.GetOrdinal("Details")),
                                Product = new Product
                                {
                                    Id = reader.GetInt32(reader.GetOrdinal("ProductId")),
                                    Name = reader.GetString(reader.GetOrdinal("ProductName")),
                                    BasePrice = reader.GetDecimal(reader.GetOrdinal("BasePrice"))
                                },
                                Order = new Order
                                {
                                    Id = reader.GetInt32(reader.GetOrdinal("OrderId")),
                                    CustomerId = reader.GetInt32(reader.GetOrdinal("CustomerId")),
                                    OrderDate = reader.GetDateTime(reader.GetOrdinal("OrderDate")),
                                    Total = reader.GetDecimal(reader.GetOrdinal("OrderTotal"))
                                }
                            };
                            orderItems.Add(orderItem);
                        }
                    }
                }
            }

            return orderItems;
        }

        public async Task AddAsync(OrderItem entity)
        {
            await _context.ExecuteNonQueryStoredProcedureAsync(
                "AddOrderItem",
                new SqlParameter("@OrderId", entity.OrderId),
                new SqlParameter("@ProductId", entity.ProductId),
                new SqlParameter("@Quantity", entity.Quantity),
                new SqlParameter("@Price", entity.Price),
                new SqlParameter("@Details", (object)entity.Details ?? DBNull.Value)
            );
        }

        public async Task UpdateAsync(OrderItem entity)
        {
            await _context.ExecuteNonQueryStoredProcedureAsync(
                "UpdateOrderItem",
                new SqlParameter("@OrderItemId", entity.Id),
                new SqlParameter("@Quantity", entity.Quantity),
                new SqlParameter("@Price", entity.Price),
                new SqlParameter("@Details", (object)entity.Details ?? DBNull.Value)
            );
        }

        public async Task RemoveAsync(int id)
        {
            await _context.ExecuteNonQueryStoredProcedureAsync(
                "RemoveOrderItem",
                new SqlParameter("@OrderItemId", id)
            );
        }
    }
}