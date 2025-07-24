export class videoStack{
  private data: number[] = []
  constructor() {}
  // push
  push(item: number): void {
    this.data.push(item)
  }
  // pop
  pop(): number | undefined{
    return this.data.pop()
  }
  // peek
  peek(): number{
    return this.data[this.data.length - 1]
  }
  // size
  size(): number {
    return this.data.length
  }
  // clear
  clear(): void {
    this.data = []
  }
  // isEmpty
  isEmpty(): boolean {
    return this.data.length === 0
  }
}

export const videoStackData: videoStack = new videoStack()