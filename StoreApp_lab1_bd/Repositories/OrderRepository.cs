using Microsoft.Data.SqlClient;
using StoreApp_lab1_bd.Data;
using StoreApp_lab1_bd.Models;

namespace StoreApp_lab1_bd.Repositories
{
    public class OrderRepository : IRepository<Order>
    {
        private readonly ApplicationDbContext _context;

        public OrderRepository(ApplicationDbContext ctx)
        {
            _context = ctx;
        }

        public async Task<IEnumerable<Order>> GetAllAsync()
        {
            return await _context.ExecuteStoredProcedureAsync<Order>("GetAllOrders");
        }

        public async Task<Order?> GetByIdAsync(int id)
        {
            return (await _context.ExecuteStoredProcedureAsync<Order>(
                "GetOrderById",
                new SqlParameter("@OrderId", id)
            )).FirstOrDefault();
        }

        public async Task AddAsync(Order entity)
        {
            await _context.ExecuteNonQueryStoredProcedureAsync(
                "AddOrder",
                new SqlParameter("@CustomerId", entity.CustomerId),
                new SqlParameter("@OrderDate", entity.OrderDate),
                new SqlParameter("@Total", entity.Total),
                new SqlParameter("@Details", (object)entity.Details ?? DBNull.Value)
            );
        }

        public async Task UpdateAsync(Order entity)
        {
            await _context.ExecuteNonQueryStoredProcedureAsync(
                "UpdateOrder",
                new SqlParameter("@OrderId", entity.Id),
                new SqlParameter("@CustomerId", entity.CustomerId),
                new SqlParameter("@OrderDate", entity.OrderDate),
                new SqlParameter("@Total", entity.Total),
                new SqlParameter("@Details", (object)entity.Details ?? DBNull.Value)
            );
        }

        public async Task DeleteAsync(int id)
        {
            await _context.ExecuteNonQueryStoredProcedureAsync(
                "DeleteOrder",
                new SqlParameter("@OrderId", id)
            );
        }
    }
}