import { describe, it, beforeEach, expect } from "vitest"

describe("Inter-reality Exchange Rate Contract", () => {
  let mockStorage: Map<string, any>
  let admin: string
  
  beforeEach(() => {
    mockStorage = new Map()
    admin = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"
  })
  
  const mockContractCall = (method: string, args: any[] = [], sender: string = admin) => {
    switch (method) {
      case "set-exchange-rate":
        if (sender !== admin) return { success: false, error: 403 }
        const [fromCurrency, toCurrency, rate] = args
        mockStorage.set(`${fromCurrency}-${toCurrency}`, { rate, last_updated: Date.now() })
        return { success: true }
      case "get-exchange-rate":
        const [getFromCurrency, getToCurrency] = args
        return { success: true, value: mockStorage.get(`${getFromCurrency}-${getToCurrency}`) }
      case "convert-value":
        const [amount, convertFromCurrency, convertToCurrency] = args
        const exchangeRate = mockStorage.get(`${convertFromCurrency}-${convertToCurrency}`)
        if (!exchangeRate) return { success: false, error: 404 }
        return { success: true, value: Math.floor((amount * exchangeRate.rate) / 100000000) }
      case "set-admin":
        if (sender !== admin) return { success: false, error: 403 }
        admin = args[0]
        return { success: true }
      default:
        return { success: false, error: "Unknown method" }
    }
  }
  
  it("should set exchange rate", () => {
    const result = mockContractCall("set-exchange-rate", ["USD", "EUR", 95000000])
    expect(result.success).toBe(true)
  })
  
  it("should get exchange rate", () => {
    mockContractCall("set-exchange-rate", ["USD", "EUR", 95000000])
    const result = mockContractCall("get-exchange-rate", ["USD", "EUR"])
    expect(result.success).toBe(true)
    expect(result.value.rate).toBe(95000000)
  })
  
  it("should convert value", () => {
    mockContractCall("set-exchange-rate", ["USD", "EUR", 95000000])
    const result = mockContractCall("convert-value", [100, "USD", "EUR"])
    expect(result.success).toBe(true)
    expect(result.value).toBe(95)
  })
})

