using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using StoreApp_lab1_bd.Models;
using StoreApp_lab1_bd.Repositories;
using YourProject.Repositories;

namespace StoreApp_lab1_bd.Controllers
{
    public class OrderItemsController : Controller
    {
        private readonly OrderItemRepository _orderItemRepository;
        private readonly IRepository<Product> _productRepository;
        private readonly IRepository<Order> _orderRepository;

        public OrderItemsController(
            OrderItemRepository orderItemRepository,
            IRepository<Product> productRepository,
            IRepository<Order> orderRepository)
        {
            _orderItemRepository = orderItemRepository;
            _productRepository = productRepository;
            _orderRepository = orderRepository;
        }

        // GET: OrderItems
        public async Task<IActionResult> Index()
        {
            var orderItems = await _orderItemRepository.GetAllAsync();
            return View(orderItems);
        }

        // GET: OrderItems/Create
        public async Task<IActionResult> Create()
        {
            await PopulateDropDownLists();
            return View();
        }

        // POST: OrderItems/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("OrderId,ProductId,Quantity,Price,Details")] OrderItem orderItem)
        {
            if (ModelState.IsValid)
            {
                await _orderItemRepository.AddAsync(orderItem);
                return RedirectToAction(nameof(Index));
            }
            await PopulateDropDownLists(orderItem.OrderId, orderItem.ProductId);
            return View(orderItem);
        }

        // GET: OrderItems/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var orderItems = await _orderItemRepository.GetAllAsync();
            var orderItem = orderItems.FirstOrDefault(oi => oi.Id == id);

            if (orderItem == null)
            {
                return NotFound();
            }

            await PopulateDropDownLists(orderItem.OrderId, orderItem.ProductId);
            return View(orderItem);
        }

        // POST: OrderItems/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("Id,OrderId,ProductId,Quantity,Price,Details")] OrderItem orderItem)
        {
            if (id != orderItem.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                await _orderItemRepository.UpdateAsync(orderItem);
                return RedirectToAction(nameof(Index));
            }
            await PopulateDropDownLists(orderItem.OrderId, orderItem.ProductId);
            return View(orderItem);
        }

        // GET: OrderItems/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var orderItems = await _orderItemRepository.GetAllAsync();
            var orderItem = orderItems.FirstOrDefault(oi => oi.Id == id);

            if (orderItem == null)
            {
                return NotFound();
            }

            return View(orderItem);
        }

        // POST: OrderItems/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            await _orderItemRepository.RemoveAsync(id);
            return RedirectToAction(nameof(Index));
        }

        private async Task PopulateDropDownLists(int? selectedOrderId = null, int? selectedProductId = null)
        {
            var products = await _productRepository.GetAllAsync();
            var orders = await _orderRepository.GetAllAsync();

            ViewBag.Products = new SelectList(products, "Id", "Name", selectedProductId);
            ViewBag.Orders = new SelectList(orders, "Id", "Id", selectedOrderId);
        }
    }
}